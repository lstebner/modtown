class HUD extends RenderedObject
    template_id: ->
        '#hud-template'

    update: (@view_data={}) ->

    setup_events: ->
        @container.on 'click', '.btn', (e) =>
            @container.trigger 'btn_pressed', $(e.target).data('action')
