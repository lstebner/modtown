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
            time_speedx: @view_data.clock.time_speedx
            balance: @view_data.town.balance
            occupancy_percent: Math.round @view_data.town.occupancy_percent * 100
            weather_season: @view_data.weather.current_season()
            weather_conditions: @view_data.weather.state.current()
            sun_is_up: if @view_data.clock.is_afternoon() then "up" else "down" #TODO: change this?

        for key, val of fill_values
            @container.find("[data-fill=#{key}]").text(val)

            $speedx = @container.find("[data-fill=time_speedx]")
            if fill_values.time_speedx == 1
                $speedx.hide()
            else
                $speedx.show().text("(#{fill_values.time_speedx}x)")


