class Crop extends RenderedObject
    constructor: ->
        super

        @can_grow_at_night = @opts.can_grow_at_night
        @drops_seeds = @opts.drops_seeds
        @harvest_amount = @opts.harvest_amount
        @growth_rate = @opts.growth_rate
        @planting_rate = @opts.planting_rate
        @needs_water = @opts.needs_water
        @type = @opts.type
        @spacing = 2
        @state_timer = new Timer()

        @state.change_state('idle')
        @is_planted = false
        @current_growth = 0

    default_opts: ->
        _.extend(
            super,
            can_grow_at_night: false
            growth_rate: .03
            planting_rate: .1
            drops_seeds: true
            harvest_amount: 1
            needs_water: true
            type: ''
        )

    space_needed: ->
        @spacing

    update: (clock) ->
        @state.update(clock)
        @state_timer.tick() if !@state_timer.complete()

        switch @state.current()
            when 'idle' then @idle()
            when 'planting' then @planting()
            when 'growing' then @growing()
            when 'fully_grown' then @fully_grown()

    plant_rate_to_ticks: ->
        WorldClock.duration(100 * @planting_rate, 'seconds')

    growth_rate_to_ticks: ->
        WorldClock.duration(100 * @growth_rate, 'seconds')

    idle: ->

    planting_time: ->
        WorldClock.duration(1, 'minutes') * @planting_rate

    reset_growth: ->

    start_planting: ->
        @state.change_state('planting')
        @state_timer.set_duration @plant_rate_to_ticks(), true

    planting: (clock) ->
        @state_timer.tick()

        if @state_timer.complete()
            @planting_finished()

    planting_finished: ->
        @is_planted = true
        @container.trigger('planting_finished')
        @state.change_state('growing')
        @state_timer.set_duration @growth_rate_to_ticks(), true

    growing: (clock) ->
        #growth only happens periodically based on the growth_rate which is a 
        #chance to progress growth on any tick
        if Math.random() < (@growth_rate * 10)
            @current_growth += @growth_rate

            if @current_growth > 100
                @finish_growing()

    growth_percent: ->
        Math.min 1, @current_growth / 100

    finish_growing: ->
        @state.change_state('fully_grown')

    fully_planted: ->
        @is_planted

    fully_grown: ->
        @state.current() == "fully_grown"






