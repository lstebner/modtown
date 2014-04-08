class FloatingMenu extends RenderedObject
    constructor: ->
        super

        if !@container.length
            @container = $('<div/>').addClass('floating-menu')
            $('body').append @container.hide()

        @title = @opts.title
        @items = @opts.items

        @default_position = @container.position()

        @setup_events()

        @open() if @opts.open

    default_opts: ->
        _.extend(
            super,
            title: 'Floating Menu'
            items: []
            open: false
        )
        

    template_id: ->
        '#floating-menu-template'

    setup_events: ->
        return unless @container.length

        @container.on 'click', (e) =>
            e.preventDefault()

            $el = $(e.target)

            if $el.is('[data-action=cancel]')
                @close()
                return @trigger 'cancel'

            @trigger 'item_selected', $el.data('action')

    get_view_data: ->
        {
            title: @title
            items: @items
        }

    #close the menu
    close: ->
        @container.hide().trigger('close')

    #open the menu
    open: ->
        @render(true)
        @container.show().trigger('open')

    #close, unbind and remove the menu
    destroy: ->
        @container.trigger('destroy').hide()
        @container.unbind().remove()

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


World.FloatingMenu = FloatingMenu
