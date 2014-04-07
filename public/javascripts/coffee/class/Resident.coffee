class Resident extends RenderedObject
    constructor: ->
        super

        @state = new StateManager('idle')

        @house = @opts.house
        @house_id = @house?.id

        @employer = @opts.employer

        @setup_stats()

    setup_stats: ->
        @sleep_schedule = 
            goto_bed: WorldClock.duration('9', 'hours')
            wake_up: WorldClock.duration('2', 'hours')

        @work_schedule = 
            goto_work: WorldClock.duration('4', 'hours')
            leave_work: WorldClock.duration('7', 'hours')

    default_opts: ->
        _.extend
            house: null
            employer: null
        , super

    update: (clock) ->
        @state.update()

        switch @state.current()
            when 'goto_bed' then @change_state('sleeping')
            when 'sleeping' then @sleep(clock)
            when 'wake_up' then @change_state('idle')
            when 'goto_work' then @change_state('working')
            when 'working' then @work(clock)
            when 'idle' then @idle(clock)

    render: ->
        #do nothing right now

    sleep: (clock) ->
        now = clock.since_midnight()

        if now > @sleep_schedule.wake_up && clock.is_morning()
            @change_state('wake_up')

    work: (clock) ->
        now = clock.since_midnight()

        if now > @work_schedule.leave_work
            @change_state('idle')

    idle: (clock) ->
        now = clock.since_midnight()

        if now > @sleep_schedule.goto_bed || now < @sleep_schedule.wake_up
            @change_state('goto_bed')
        else if @employer && now > @work_schedule.goto_work
            @change_state('goto_work')
