# @codekit-prepend "Crop.coffee";

some_crops = 
    wheat:
        name: 'Wheat'
    potatos:
        name: 'Potatos'
    carrots: 
        name: 'Carrots'
    rice:
        name: 'Rice'
    grapes:
        name: 'Grapes'

some_crop_menu_items = {}
for key, crop of some_crops
    some_crop_menu_items[key] = crop.name

    some_crops[key] = new Crop null, _.extend(crop, { type: key })

class Farm extends Structure
    constructor: ->
        super

        @available_crops = some_crops # @opts.available_crops
        @crop = @opts.crop
        @till_soil_time = WorldClock.duration .3, 'minutes'
        @soil_ready = false
        @acres = 1 #1 acre in sq ft = 43560
        @crop_capacity = 0
        @plots_per_acre = 0
        @planted_crops = []
        @harvested_crops = []
        @state_timer = new Timer()

        @plots_available()
    
    default_opts: ->
        _.extend(
            super,
            construction_time: WorldClock.duration 5, 'seconds'
            crop: null
            available_crops: []
        )

    get_view_data: ->
        percent_complete = if @state.current() == "planting"
            @planted_crops.length / @crop_capacity
        else
            @state_timer.percent_complete()

        _.extend(
            super,
            crop: @crop
            crop_state: @crop_state
            state: @state
            percent_complete: Math.round(percent_complete * 100)
            soil_ready: @soil_ready
            harvested_crops: @harvested_crops
            planted_crops: @planted_crops
        )

    template_id: ->
        '#farm-template'

    begin_construction: ->
        @construction_time = WorldClock.duration(10, 'seconds')
        super

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            switch $el.data('action')
                when 'select_crop'
                    select_crop_menu = new SelectCropMenu null, 
                        open: true
                        items: some_crop_menu_items
                    select_crop_menu.container.on 'item_selected', (e, value) =>
                        if _.has @available_crops, value
                            @set_crop @available_crops[value]

                when 'start_planting' then @state.change_state('start_planting')

    update: (clock) ->
        super

        #parent Structure class can take care of everything during construction
        return if @is_under_construction()

        switch @state.current()
            #Structure triggers this one by default when construction completes
            when 'operating' then @state.change_state('idle')
            when 'idle' then @idle()
            when 'start_planting' then @start_planting()
            when 'tilling_soil' then @till_soil(clock)
            when 'planting' then @planting(clock)
            when 'growing' then @growing(clock)
            when 'harvesting' then @harvest(clock)
            when 'reset' then @reset(clock)

    idle: ->

    can_change_crop: ->
        return @state.current() == "idle"

    crops_per_acre: ->
        return unless @crop

        # 43560 is the amount of real sq ft per acre. Not sure if that'll work
        # for our game though honestly
        @plots_per_acre = 10 / @crop.spacing
        @crop_capacity = Math.floor(@plots_per_acre * @acres)

        @plots_per_acre

    total_plots: ->
        Math.floor(@plots_per_acre * @acres)

    plots_available: ->
        @total_plots() - @planted_crops.length

    set_crop: (new_crop, start_planting=true) ->
        return unless @can_change_crop()

        @crop = new_crop
        @crops_per_acre()

        if start_planting
            if @state.current() != 'idle'
                @reset()
            else
                @start_planting() 

    start_planting: ->
        @state.change_state('tilling_soil')
        @state_timer.set_duration @till_soil_time
        @state_timer.reset()

    till_soil: (clock) ->
        @state_timer.tick()

        if @state_timer.complete()
            @soil_ready = true
            @state.change_state('planting')
            @state_timer.set_duration @crop.planting_time(clock), true

    planting: (clock) ->
        return unless @crop && clock.is_afternoon()

        # Planting
        # Each plant requires a certain amount of time to be planted
        # The farm has a certain number of "plots" available to plant on
        # Planting is complete when every plot has a plant in it. 

        #once we run out of plots, we are done planting
        if !@plots_available()
            @finish_planting()
        else
            last = if @planted_crops.length
                @planted_crops.length - 1
            else
                false

            #if the last plant is not done planting yet then give it priority
            if last != false && !@planted_crops[last].fully_planted()
                @planted_crops[last].update(clock)
            #otherwise, start a new plant
            else
                new_plant = new Crop null, @available_crops[@crop.type]
                new_plant.start_planting()
                @planted_crops.push new_plant

    #transition state
    finish_planting: (trigger_event='complete') ->
        @container.trigger("planting_#{trigger_event}") if trigger_event?
        @state.change_state('growing')
        @state_timer.set_duration @crop_capacity, true

    growing: (clock) ->
        return unless @planted_crops.length

        all_grown = false

        for c in @planted_crops
            c.update(clock)

            if c.fully_planted()
                @state_timer.tick()
            if @planted_crops.length == @crop_capacity && c.fully_planted()
                all_grown = true

        if all_grown
            @state.change_state('harvest')

    harvest: (clock) ->
        done = false

        if done
            @state.change_state('reset')

    reset: (clock) ->

    replant: ->
        @state.change_state('.planting')

    employ_resident: (resident) ->





