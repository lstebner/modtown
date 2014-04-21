class Crop extends RenderedObject
    constructor: ->
        super

        @can_grow_at_night = @opts.can_grow_at_night
        @drops_seeds = @opts.drops_seeds
        @harvest_amount = @opts.harvest_amount
        @units = @opts.units
        @growth_rate = @opts.growth_rate
        @planting_rate = @opts.planting_rate
        @harvest_rate = @opts.harvest_rate
        @needs_water = @opts.needs_water
        @type = @opts.type
        @spacing = 2
        @state_timer = new Timer()
        @actual_harvest_amount = 0
        @value = @opts.value

        @state.change_state('idle')
        @is_planted = false
        @current_growth = 0

    default_opts: ->
        _.extend(
            super,
            can_grow_at_night: false
            growth_rate: .9
            planting_rate: .1
            harvest_rate: .1
            drops_seeds: true
            harvest_amount: [1, 3]
            needs_water: true
            type: ''
            value: 1
            units: ''
        )

    space_needed: ->
        @spacing

    update: (clock) ->
        super

        switch @state.current()
            when 'idle' then @idle()
            when 'planting' then @planting()
            when 'growing' then @growing()
            when 'harvesting' then @harvesting()
            when 'harvested' then @harvested()
            when 'fully_grown' then @fully_grown()

    plant_rate_to_ticks: ->
        WorldClock.duration(100 * @planting_rate, 'seconds')

    growth_rate_to_ticks: ->
        WorldClock.duration(100 * @growth_rate, 'seconds')

    harvest_rate_to_ticks: ->
        WorldClock.duration(100 * @harvest_rate, 'seconds')        

    idle: ->

    reset_growth: ->

    start_planting: ->
        @state.change_state('planting')
        @state_timer.set_duration @plant_rate_to_ticks(), true, "auto"

    planting: (clock) ->
        if @state_timer.is_complete()
            @planting_finished()

    planting_finished: ->
        @is_planted = true
        @container.trigger('planting_finished')
        @state.change_state('growing')
        @state_timer.set_duration @growth_rate_to_ticks(), true, "auto"

    calculate_harvest_amount: ->
        Math.floor(Math.random() * @harvest_amount[1]) + @harvest_amount[0]

    start_harvest: ->
        @state.change_state('harvesting')
        @state_timer.set_duration @harvest_rate_to_ticks(), true, "auto"

    harvesting: ->
        if @state_timer.is_complete()
            @actual_harvest_amount = @calculate_harvest_amount()
            @state.change_state('harvested')

    harvested: ->
        #do nothing state

    growing: (clock) ->
        #growth only happens periodically based on the growth_rate which is a 
        #chance to progress growth on any tick
        if Math.random() < (@growth_rate * 10)
            @current_growth += @growth_rate

            if @current_growth > 10#0
                @finish_growing()

    current_growth_percent: ->
        Math.min 1, @current_growth / 10#0

    finish_growing: ->
        @state.change_state('fully_grown')

    fully_planted: ->
        @is_planted

    fully_grown: ->
        @state.current() == "fully_grown"

    fully_harvested: ->
        @state.current() == "harvested"

    harvested_amount: ->
        @actual_harvest_amount






