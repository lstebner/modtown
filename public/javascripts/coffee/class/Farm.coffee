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

class Farm extends Structure
    constructor: ->
        super

        @available_crops = some_crops # @opts.available_crops
        @crop = @opts.crop
        @crop_state = new StateManager('not_planted')
        @till_soil_time = WorldClock.duration 1, 'minutes'
        @soil_ready = false
        @harvested_crops = []
    
    default_opts: ->
        _.extend(
            super,
            construction_time: WorldClock.duration 5, 'seconds'
            crop: null
            available_crops: []
        )

    get_view_data: ->
        _.extend(
            super,
            crop: @crop
            crop_state: @crop_state
            state: @state
            soild_ready: @soild_ready
            harvested_crops: @harvested_crops
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
                            @crop = @available_crops[value]

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

    #todo: implement
    can_change_crop: ->
        return @state.current() == "idle"

    set_crop: (new_crop, start_planting=true) ->
        return unless @can_change_crop()

        @crop = new_crop

        if start_planting
            if @state.current() != 'idle'
                @reset()
            else
                @start_planting() 

    start_planting: ->
        @state.change_state('tilling_soil')

    till_soil: (clock) ->
        done = false

        if done
            @soil_ready = true
            @state.change_state('planting')

    planting: (clock) ->
        return unless clock.is_afternoon()

        done = false

        if done
            @state.change_state('growing')

    growing: (clock) ->
        done = false

        if done
            @state.change_state('harvest')

    harvest: (clock) ->
        done = false

        if done
            @state.change_state('reset')

    reset: (clock) ->

    replant: ->
        @state.change_state('.planting')

    employ_resident: (resident) ->
