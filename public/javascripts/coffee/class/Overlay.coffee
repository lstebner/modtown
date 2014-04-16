class Overlay extends RenderedObject
    show: ->
        return if @container.hasClass('show') || @container.hasClass('transitioning')
        @container.addClass('transitioning').fadeIn =>
            @container.removeClass('transitioning').addClass('show')

    hide: ->
        @container.fadeOut =>
            @container.removeClass('show')

World.Overlay = Overlay
