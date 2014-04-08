class HUD extends RenderedObject
    template_id: ->
        '#hud-template'

    update: (@view_data={}) ->

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            if $el.is('.btn')
                @container.trigger 'btn_pressed', $el.data('action')

    render: ->
        super

        fill_values = 
            calendar_month: @view_data.clock.get_month()
            calendar_year: @view_data.clock.get_year()
            clock_time: @view_data.clock.get_time('h:m:s')
            balance: @view_data.town.balance
            occupancy_percent: Math.round @view_data.town.occupancy_percent * 100

        for key, val of fill_values
            @container.find("[data-fill=#{key}]").text(val)

