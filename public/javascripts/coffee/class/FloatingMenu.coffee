class FloatingMenu extends RenderedObject
    constructor: ->
        super

        if !@container.length
            @container = $('<div/>').addClass('floating-menu')
            $('body').append @container.hide()

        @title = @opts.title
        @items = @opts.items

        @setup_events()

    default_opts: ->
        _.extend
            title: 'Floating Menu'
            items: []
        , super

    template_id: ->
        '#floating-menu-template'

    setup_events: ->
        return unless @container.length

        @container.on 'click', (e) =>
            e.preventDefault()

            $el = $(e.target)

            if $el.is('[data-action=cancel]')
                @close()

            @trigger $el.data('action')

    get_view_data: ->
        {
            title: @title
            items: @items
        }

    close: ->
        @container.hide()

    open: ->
        @render(true)
        @container.show()

    destroy: ->
        @container.unbind()
        @container.remove()

    set_position: (x, y) ->
        @container.css
            top: y
            left: x

    trigger: (event_name) ->
        @container.trigger 'item_selected', event_name


World.FloatingMenu = FloatingMenu
