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

    template_id: ->
        '#warehouse-template'

    operating: (clock) ->
        return if @is_under_construction()

    setup_delivery_trucks: ->
        for i in [1..@num_trucks]
            new_truck = new DeliveryTruck()

            @trucks.push(new_truck)

    next_available_truck: ->
        truck = null

        for t in @trucks
            truck = t if !truck && t.is_parked()

        truck

    queue_delivery: (where) ->

    goto_next_delivery: ->
        return false unless @delivery_queue.length

    queue_pickup: (where) ->

    goto_next_pickup: ->
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


