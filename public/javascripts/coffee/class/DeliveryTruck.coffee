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
        @storage = {}
        @total_stored = 0

        @set_destination @opts.destination
        @current_location = null

    update: (clock) ->
        super

        switch @state.current()
            when 'driving' then @driving()
            when 'loading' then @unloading()
            when 'unloading' then @unloading()

    actual_capacity: ->
        return if @capacity >= DeliveryTruck.capacities.length || @capacity < 0
            0
        else
            DeliveryTruck.capacities[@capacity]

    begin_loading: ->
        @state.change_state('loading')
        @state_timer.set_duration 100

    begin_unloading: ->
        @state.change_state('unloading')
        @state_timer.set_duration @total_stored * 10

    is_full: ->
        @total_stored == @actual_capacity()

    is_empty: ->
        @total_stored == 0

    set_driver: (resident) ->
        return unless @is_parked()

        @driver = resident

    has_driver: ->
        return @driver != null

    set_passenger: (resident) ->
        return unless @is_parked()

        @passenger = resident

    park: ->
        @state.change_state('parked')

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
        return unless @is_parked() && destination

        if is_address
            @destination_address = destination
        else
            @destination_address = destination.address
            @destination = @destination

        @state_timer.set_duration World.gps.get_travel_time_between @current_location, @destination_address, @drive_speed
        @state.change_state('driving') if start_driving && @has_driver()

    return_to_warehouse: ->
        return unless @warehouse_address.is_valid()

        @set_destination @warehouse_address, true

    driving: ->
        @state_timer.update()

        if @state_timer.is_complete()
            if @is_at_destination()
                @begin_loading()
            else if @is_at_warehouse()
                @begin_unloading()

    loading: ->
        @state_timer.update()

        if @state_timer.is_complete()
            @return_to_warehouse()

    unloading: ->
        @state_timer.update()

        if @state_timer.is_complete()
            @park()




