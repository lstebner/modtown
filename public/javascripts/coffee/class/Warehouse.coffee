# @codekit-prepend "DeliveryTruck.coffee";

class Structure.Warehouse extends Structure
    constructor: ->
        super

        @num_trucks = @opts.num_trucks
        @num_trucks_available = 0
        @trucks = []
        @storage_capacity = 1000
        @total_stored = 0

        @pickup_queue = []
        @delivery_queue = []

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
            trucks_available: @num_trucks_available
        )

    template_id: ->
        '#warehouse-template'

    settings_menu_items: ->
        view_info: 'Stats'
        close: 'Close'

    settings_item_selected: (value) ->
        switch value
            when 'view_info'
                World.Popup.Create
                    title: "#{@name} Stats"
                    wide: true
                    body_template: "#warehouse-stats-template"
                    view_data: { warehouse: @ }

                @close_settings_menu()

    operating: (clock) ->
        return if @is_under_construction()

        @update_trucks(clock)

        # are there any new pickup requests?
        if @pickup_queue.length
            # are there any trucks available with drivers?
            if @num_trucks_available
                # send the driver on the pickup
                @send_truck_to_next_pickup()

        # do the same thing for deliveries

        # potenital problems:
            # with this setup, pickups will always get priority over deliveries
                # this could potentially be a toggle
                # this could also be solved with some alternating logic

    update_trucks: (clock) ->
        for t in @trucks
            t.update(clock)

            if t.state.current() == "unloading_complete"
                @storage.take_all_items_from t.storage
                t.park()

        @get_num_trucks_available()

    setup_delivery_trucks: ->
        for i in [1..@num_trucks]
            new_truck = new DeliveryTruck
                warehouse_address: @address
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

    assign_driver: (truck) ->
        return truck if truck.has_driver()

        for employee in @employees
            if !employee.role
                truck.set_driver employee
                break

        truck

    queue_pickup: (where) ->
        @pickup_queue.push where

    send_truck_to_pickup: (loc) ->
        truck = @next_available_truck()
        @assign_driver truck
        truck.set_destination loc, false, true

    send_truck_to_next_pickup: ->
        return false unless @pickup_queue.length

        @send_truck_to_pickup @pickup_queue.shift()

    get_num_trucks_available: ->
        return 0 if !@trucks.length

        count = 0
        for t in @trucks
            count += 1 if t.is_available()

        @num_trucks_available = Math.min @employees.length, count

