class DeliveryTruck extends StateObject
    @capacities: [0, 100, 500, 1000]

    get_default_opts: ->
        driver: null
        passenger: null
        destination: null
        drive_speed: 1
        capacity: 1 #points to index of @capacities
        warehouse_address: new Address()

    constructor: (opts={}) ->
        super

        @opts = _.extend @get_default_opts(), opts

        @driver = @opts.driver
        @passenger = @opts.passenger
        @drive_speed = @opts.drive_speed
        @capacity = @opts.capacity
        @warehouse_address = @opts.warehouse_address
        @storage = new Storage @actual_capacity()

        @set_destination @opts.destination
        @current_location = @warehouse_address

        @state.on 'state_changed', (current, previous) =>
            console.log 'truck change', current, previous

    update: (clock) ->
        super

        switch @state.current()
            when 'driving' then @driving()
            when 'loading' then @loading()
            when 'unloading' then @unloading()
            when 'parked'
                if @is_at_warehouse() && @has_driver() && @destination
                    @set_destination @destination, false, true

    actual_capacity: ->
        return if @capacity >= DeliveryTruck.capacities.length || @capacity < 0
            0
        else
            DeliveryTruck.capacities[@capacity]

    begin_loading: ->
        @state.change_state('loading')
        @state_timer.set_duration 10, true

    begin_unloading: ->
        @state.change_state('unloading')
        @state_timer.set_duration @storage.get_num_items() * 1, true

    set_driver: (resident) ->
        return unless @is_parked()

        @driver = resident
        resident.assign_role 'truck_driver'

    release_driver: (resident) ->
        return unless @driver

        @driver.release_role() 
        @driver = null

    has_driver: ->
        return @driver != null

    set_passenger: (resident) ->
        return unless @is_parked()

        @passenger = resident

    park: (release_driver=true) ->
        @state.change_state('parked')
        @release_driver() if release_driver

    is_parked: ->
        @state.current() == "parked"

    is_in_service: ->
        true

    is_available: ->
        @is_parked() && @is_in_service()

    is_at_destination: ->
        Address.compare @current_location, @destination_address

    is_at_warehouse: ->
        Address.compare @current_location, @warehouse_address

    set_destination: (destination=null, is_address=false, start_driving=false) ->
        return unless destination

        if is_address
            @destination_address = destination
        else
            @destination_address = destination.address
            @destination = destination

        travel_time = World.gps.get_travel_time_between @current_location, @destination_address, @drive_speed
        @state_timer.set_duration travel_time, true
        @state.change_state('driving') if start_driving && @has_driver()

    return_to_warehouse: ->
        return unless @warehouse_address.is_valid()

        @set_destination @warehouse_address, true, true

    driving: ->
        if @state_timer.is_complete()
            @current_location = @destination_address

            if @is_at_warehouse()
                @begin_unloading()
            else if @is_at_destination()
                @begin_loading()

    loading: ->
        if @state_timer.is_complete()
            items = {}
            total_amount = 0

            if @destination
                @storage.take_all_items_from @destination.storage, 'all'

            @return_to_warehouse()

    unloading: ->
        if @state_timer.is_complete()
            @state.change_state('unloading_complete')




