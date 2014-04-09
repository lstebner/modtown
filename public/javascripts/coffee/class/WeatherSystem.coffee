class WeatherSystem
    @seasons: ['Spring', 'Summer', 'Fall', 'Winter']
    @months_in_season: 4
    @days_in_season: WeatherSystem.months_in_season * WorldClock.days_in_month
    @get_season: (month) ->
        WeatherSystem.seasons[Math.floor(month / WeatherSystem.months_in_season) % Calendar.seasons.length]

    constructor: ->
        @state = new StateManager('sunny')
        @season = 0

        @year_progress = 0
        @season_progress = 0
        @weather_system_started = 0

        @state = new StateManager('sunny')
        @sun_state = new StateManager('set')
        @clouds_state = new StateManager('clear')
        @time_of_day_state = new StateManager('morning')

        @sun_schedule = []
        @create_sun_schedule()
        @temperature = 0
        @temperature_highs_lows = []

    create_sun_schedule: ->
        @sun_schedule = []

        for i in [1..WorldClock.days_in_year]
            adjust = Math.sin(i / WorldClock.days_in_year) * .2

            @sun_schedule.push
                rise_time: (.2 + adjust) * WorldClock.seconds_in_day
                set_time: (.8 - adjust) * WorldClock.seconds_in_day

    current_season: ->
        WeatherSystem.seasons[@season]

    update_sun: (day, time_as_seconds) ->
        schedule = @sun_schedule[day]
        rise_time = WorldClock.duration '40', 'minutes'
        set_time = rise_time

        switch @sun_state.current()
            when 'set'
                if time_as_seconds < day.rise_time
                    if time_as_seconds + rise_time > day.rise_time
                        @sun_state.change_state 'rising'
                        @time_of_day_state.change_state 'morning'
            when 'rising'
                if time_as_seconds >= day.rise_time
                    @sun_state.change_state 'up'
            when 'up'
                if time_as_seconds + set_time > day.set_time
                    @sun_state.change_state 'setting'
                else if time_as_seconds > WorldClock.seconds_in_day * .42
                    @time_of_day_state.change_state 'afternoon'
            when 'setting'
                if time_as_seconds >= day.set_time
                    @sun_state.change_state 'set'
                    @time_of_day_state.change_state 'night'

    update: (clock) ->
        day_index = clock.day_in_year()

        @season = Math.floor day_index / WeatherSystem.days_in_season
        @year_progress = day_index / WorldClock.days_in_year
        @season_progress = (day_index % WeatherSystem.days_in_season) / WeatherSystem.days_in_season

        @update_sun day_index, clock.since_midnight()

        switch @current_season()
            when 'Spring' then @spring(clock)
            when 'Summer' then @summer(clock)
            when 'Fall' then @fall(clock)
            when 'Winter' then @winter(clock)

        @state.update()
        @clouds_state.update()
        @sun_state.update()
        @time_of_day_state.update()

    #make it rain
    begin_raining: (duration=0, timenow=0) ->
        strength = Math.random() + .4

        @weather_system_ends_at = strength * WeatherSystem.avg_spring_rain_duration
        @weather_system_started = timenow
        @state.change_state('raining')

    stop_raining: ->
        @weather_system_ends_at = null
        @weather_system_started = 0
        @state.change_state 'clear'

    spring: (clock) ->
        avg_rain_duration = WorldClock.duration 3, 'hours'
        switch @state.current()
            when 'clear'
                if Math.random() < WeatherSystem.spring_rain_chance
                    @begin_raining(clock.now(), WeatherSystem.avg_spring_rain_duration)

            when 'raining'
                if clock.now() > @weather_system_ends_at
                    @stop_raining()

            else
                @state.change_state 'clear'


    summer: (clock) ->
        @state.change_state('clear') if @state.current() != 'clear'

    fall: (clock) ->
        @state.change_state('overcast') if @state.current() != 'overcast'

    winter: (clock) ->
        @state.change_state('clear') if @state.current() != 'clear'

World.WeatherSystem = WeatherSystem
