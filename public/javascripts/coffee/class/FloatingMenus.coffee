class BuildMenu extends FloatingMenu
    constructor: ->
        super

        @block_id = @opts.block_id
        @street_id = @opts.street_id
        @town = @opts.town

    default_opts: ->
        _.extend(
            super,
            block_id: -1
            street_id: -1
            town: null
            title: 'Build Menu'
            items:
                build_farm: "Build Farm"
                build_factory: "Build Factory"
                build_housing: "Build Housing"
        )


    trigger: (event_name='item_selected', value) ->
        super

        if @town && event_name == 'item_selected'
            switch value
                when 'build_farm' then @town.build_structure 'farm', @street_id, @block_id
                when 'build_factory' then @town.build_structure 'factory', @street_id, @block_id
                when 'build_housing' then @town.build_structure 'housing', @street_id, @block_id

            @destroy()

class VisitorMenu extends FloatingMenu
    constructor: ->
        super

        @visitor = @opts.visitor
        @town = @opts.town
        @housing = @town.get_housing()

        @setup_house_menu()

    default_opts: ->
        _.extend(
            super,
            visitor: null
            town: null
            title: 'Visitor Actions'
            items: 
                move_in: "Move In"
                kick_out: "Kick Out"
        )

    setup_house_menu: ->
        @select_house_menu = new SelectHouseMenu null, 
            housing: @housing

    trigger: (event_name='item_selected', value=null) ->
        super

        if event_name == 'item_selected'
            switch value
                when 'move_in' then @move_in_to_town()
                when 'kick_out' then @kick_out_of_town()

        @destroy()

    move_in_to_town: ->
        return unless @town && @visitor

        @select_house_menu.open()

        @select_house_menu.container.one 'house_selected', (e, house_id) =>
            house_id = parseInt house_id.replace("house_", "")
            for house in @housing
                if house.id == house_id
                    @town.convert_visitor_to_resident @visitor.id
                    house.move_resident_in @visitor


    kick_out_of_town: ->
        return unless @town && @visitor

        @town.remove_visitor @visitor.id

class SelectHouseMenu extends FloatingMenu
    constructor: ->
        super

        @housing = @opts.housing

        @setup_items()

    setup_items: ->
        return unless @housing

        @items = {}

        for house in @housing
            @items["house_#{house.id}"] = house.name

        @render(true)

    default_opts: ->
        _.extend(
            super,
            title: 'Select Home'
            housing: []
        )

    trigger: (event_name='item_selected', value=null) ->
        super

        if event_name == 'item_selected'
            @trigger 'house_selected', value

        @destroy()

class ResidentMenu extends FloatingMenu
    constructor: ->
        super

        @resident = @opts.resident
        @set_title @resident.name

        @view_data = @get_view_data()

        @render(true)

    default_opts: ->
        _.extend(
            super,
            resident: null
            items: 
                show_stats: 'Show Stats'
                assign_job: 'Assign Job'
                evict: 'Evict'
        )

class SelectCropMenu extends FloatingMenu
    constructor: ->
        super

        @crops = @opts.crops

        @view_data = @get_view_data()

        @render(true)

    default_opts: ->
        _.extend(
            super,
            title: 'Select Crop'
            items: []
        )

    trigger: ->
        super

        @destroy()

class FluxMenu extends FloatingMenu
    constructor: ->
        super

        @clock = @opts.clock

        @set_position 10, 10

    default_opts: ->
        _.extend(
            super,
            title: 'Flux Menu'
            clock: new WorldClock()
            items:
                pause_time: 'Pause Time'
                resume_time: 'Resume Time'
                speed_up_time: 'Speed up Time'
                slow_down_time: 'Slow Down Time'
                default_time: 'Reset Time Speed'
                add_one_hour: 'Add 1 Hour'
        )

    trigger: (event_name='item_selected', value) ->
        if event_name == 'item_selected'
            switch value
                when 'pause_time' then @pause_time()
                when 'resume_time' then @resume_time()
                when 'speed_up_time' then @speed_up_time()
                when 'slow_down_time' then @slow_down_time()
                when 'default_time' then @default_time()
                when 'add_one_hour' then @add_one_hour()

    add_one_hour: ->
        @clock?.add_time 1, 'hours'

    pause_time: ->
        @clock?.pause_time()

    resume_time: ->
        @clock?.resume_time()

    speed_up_time: ->
        @clock?.time_speed_plus()

    slow_down_time: ->
        @clock?.time_speed_minus()

    default_time: ->
        @clock?.time_speed_default()

World.FluxMenu = FluxMenu







