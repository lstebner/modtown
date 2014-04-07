class WorldClock
    #this flag can be used to speed up the clock for testing
    @double_time: false

    @max_seconds: 60
    @max_minutes: 60
    @max_hours: 10
    @max_days: 30
    @max_months: 16
    @seconds_in_minute: WorldClock.max_seconds
    @seconds_in_hour: WorldClock.seconds_in_minute * WorldClock.max_minutes
    @seconds_in_day: WorldClock.seconds_in_hour * WorldClock.max_hours
    @seconds_in_month: WorldClock.seconds_in_day * WorldClock.max_days
    @seconds_in_year: WorldClock.seconds_in_month * WorldClock.max_months

    @get_duration: (amount, of_what='seconds') ->
        in_seconds = 0

        switch of_what
            when 'seconds' || 's' then in_seconds = amount
            when 'minutes' || 'm' then in_seconds = amount * WorldClock.seconds_in_minute
            when 'hours' || 'h' then in_seconds = amount * WorldClock.seconds_in_hour
            when 'days' || 'd' then in_seconds = amount * WorldClock.seconds_in_day
            when 'months' || 'mo' then in_seconds = amount * WorldClock.seconds_in_month
            when 'years' || 'y' then in_seconds = amount * WorldClock.seconds_in_year

        in_seconds

    constructor: ->
        @since_epoch = 0
        @second = 0
        @minute = 0
        @hour = 0
        @day = 0
        @month = 0
        @year = 0

        @timeout = null
        @timers = []

    tick: (set_timeout=true)->
        @update()

        if set_timeout
            clearTimeout(@timeout) if @timeout

            onetick = if WorldClock.double_time
                100
            else
                1000

            @timeout = setTimeout =>
                @tick()
            , onetick

    sync: ->
        #sync with a real server

    update: ->
        @since_epoch += 1

        if @since_epoch < WorldClock.max_seconds
            @second = @since_epoch
        else 
            @second = @since_epoch  % WorldClock.max_seconds
        @minute = @since_epoch / WorldClock.seconds_in_minute % WorldClock.max_minutes
        @hour = @since_epoch / WorldClock.seconds_in_hour % WorldClock.max_hours
        @day = Math.floor @since_epoch / WorldClock.seconds_in_day
        @month = Math.floor @since_epoch / WorldClock.seconds_in_month
        @year = Math.floor @since_epoch / WorldClock.seconds_in_year

        @update_timers()

    update_timers: ->
        for timer in @timers
            timer.tick()

    now: ->
        @get_time()

    get_time: (format=null) ->
        return @since_epoch if !format

        format = format.replace 'h', @get_hours(true)
        format = format.replace 'm', @get_minutes(true)
        format = format.replace 's', @get_seconds(true)
        format = format.replace 'd', @get_day()
        format = format.replace 'y', @get_year()
        format = format.replace 'mo', @get_month()

        format

    get_hours: (format=false) ->
        h = Math.floor @hour

        if format
            if h < 10
                '0' + h.toString()
            else
                h.toString()
        else
            h

    get_minutes: (format=false) ->
        m = Math.floor @minute

        if format
            if m < 10
                '0' + m.toString()
            else
                m.toString()
        else
            m

    get_seconds: (format=false) ->
        s = Math.floor @second
        if format
            if s < 10
                '0' + s.toString()
            else
                s.toString()
        else
            @second

    get_day: ->
        Calendar.get_day @day

    get_year: ->
        @year + 1

    get_month: ->
        Calendar.get_month @month

    create_timer: (duration=0, on_complete=null) ->
        new_timer = new Timer duration, on_complete
        @timers.push new_timer

        new_timer

World.WorldClock = WorldClock
