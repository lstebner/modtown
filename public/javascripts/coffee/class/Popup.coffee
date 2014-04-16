class Popup extends RenderedObject
    constructor: ->
        super

        if !@container.length
            @container = $('<div/>').addClass('popup')
            $('body').append @container.hide()

        @title = @opts.title
        @message = @opts.message
        @is_modal = @opts.is_modal
        @set_body_template @opts.body_template

        @default_position = @container.position()

        @setup_events()

        @render(true)

        @open() if @opts.open

    default_opts: ->
        _.extend(
            super,
            title: 'Popup Item'
            body_template: null
            open: false
            message: ''
            is_modal: false
        )
        
    template_id: ->
        '#popup-template'

    setup_events: ->
        return unless @container.length

        @container.on 'click', (e) =>
            e.preventDefault()

            $el = $(e.target)

            if $el.is('[data-action=cancel]')
                @close()
                return @trigger 'cancel'

    set_body_template: (template_id=null, render=false) ->
        return unless template_id

        if !$(template_id).length
            throw("Body Template #{template_id} not found")

        @body_template = _.template $("#{template_id}").html()

        @render(true) if render

    get_view_data: ->
        _.extend(
            super,
            title: @title
            message: @message
        )

    #close the menu
    close: ->
        if @is_modal
            World.window_overlay.hide()

        @container.hide().trigger('close')

    #open the menu
    open: ->
        if @is_modal
            World.window_overlay.show()

        @render(true)
        @container.show().trigger('open')

    #close, unbind and remove the menu
    destroy: ->
        if @is_modal
            World.window_overlay.hide()

        @container.trigger('destroy').hide()
        @container.unbind().remove()

    set_title: (new_title) ->
        @title = new_title
        @set_view_data 'title', @title
        @render(true)
        @container.trigger('title_changed')

    set_message: (new_message) ->
        @message = new_message
        @set_view_data 'message', @message
        @render(true)

    #move the menu to a certain position
    set_position: (x, y) ->
        @container.css
            top: y
            left: x

    #set the position to the closest point deemed safe to 
    #the passed in x,y coordinates
    best_position_for: (x, y) ->
        x_padding = 100
        y_padding = -@container.height() / 3

        right_edge = x + @container.width() + x_padding
        #check if there is not enough room to the right
        if right_edge > $(window).width()
            #and then set it to the left
            x = x - @container.width() - x_padding
        #otherwise set it to the right
        else
            x += x_padding

        #don't go below 0
        if y + y_padding < 0
            y = y_padding
        #don't go over window height
        else if y + y_padding > $(window).height()
            y = $(window).height() - @container.height() - y_padding
        #safe
        else
            y += y_padding

        @set_position x, y

    trigger: (event_name='item_selected', value) ->
        @container.trigger event_name, value

    render_body: ->
        return unless @body_template

        @container.find('.body').empty()
        @container.find('.body').html @body_template @get_view_data()

    render: ->
        super

        @render_body() if @body_template


World.Popup = Popup
