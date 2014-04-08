_next_id = 0
_auto_id = ->
    _next_id += 1

class RenderedObject
    constructor: (container, opts={}) ->
        @container = $ container
        @tmpl = @set_template @template_id()
        @rendered = false
        @view_data = {}
        @set_opts opts

        @name = if @opts.name? then @opts.name else ''
        @id = if @opts.id? then @opts.id else _auto_id()

        @setup_events()

        @render() if @opts.render

    change_state: (new_state) ->
        @state.change_state new_state

    default_opts: ->
        {
            name: ''
            render: false
        }

    set_opts: (opts={}) ->
        @opts = _.extend @default_opts(), opts

    template_id: ->
        null

    set_template: (tmpl_id) ->
        return null if !tmpl_id

        new_tmpl = _.template $(tmpl_id).html()
        return unless new_tmpl

        @tmpl = new_tmpl

    get_view_data: ->
        {}

    set_view_data: (key, val) ->
        @view_data[key] = val

    clear_view_data: ->
        @view_data = []

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()

    render: (force=false) ->
        return if (@rendered && !force) || !@tmpl

        @container.empty()
        @container.html @tmpl _.extend @view_data, @get_view_data()
        @rendered = true
