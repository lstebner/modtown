# @codekit-prepend "DeliveryTruck.coffee";

class Warehouse extends Structure
    constructor: ->
        super

        @num_trucks = @opts.num_trucks
        @trucks = []
        @storage_capacity = 1000
        @total_stored = 0

        @pickup_queue = []
        @delivery_queue = []
        @storage = {}

        @setup_delivery_trucks()

    default_opts: ->
        _.extend(
            super,
            name: 'Warehouse'
            construction_time: WorldClock.duration(10, 'seconds')
            num_trucks: 3
            max_employees: 5
        )

    get_view_data: ->
        _.extend(
            super,
            trucks_available: @num_trucks_available()
        )

    template_id: ->
        '#warehouse-template'

    settings_menu_items: ->
        view_info: 'Stats'
        close: 'Close'

    operating: (clock) ->
        return if @is_under_construction()

        @update_trucks(clock)

        # are there any new pickup requests? 
            # are there any trucks available with drivers?
                # send the driver on the pickup

        # do the same thing for deliveries

        # potenital problems:
            # with this setup, pickups will always get priority over deliveries
                # this could potentially be a toggle
                # this could also be solved with some alternating logic

    update_trucks: (clock) ->
        for t in @trucks
            t.update(clock)

    setup_delivery_trucks: ->
        for i in [1..@num_trucks]
            new_truck = new DeliveryTruck()
            new_truck.park()

            @trucks.push(new_truck)

    next_available_truck: ->
        truck = null

        for t in @trucks
            truck = t if !truck && t.is_parked()

        truck

    queue_delivery: (where) ->

    send_truck_to_delivery: (delivery) ->

    send_truck_to_next_delivery: ->

    queue_pickup: (where) ->

    send_truck_to_pickup: (loc) ->

    send_truck_to_next_pickup: ->
        return false unless @pickup_queue.length

    store: (what, how_many) ->
        @storage[what] = 0 if !_.has @storage, what

        @storage[what] += how_many

        @check_storage_capacity()

    check_storage_capacity: ->
        @total_stored = 0

        for amount in @storage
            @total_stored += amount

        @state.change_state('over capacity') if @is_over_capacity()

    is_over_capacity: ->
        @total_stored > @storage_capacity

    num_trucks_available: ->
        return 0 if !@trucks.length

        count = 0
        for t in @trucks
            count += 1 if t.is_available()

        Math.min @employees.length, count

