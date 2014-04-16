class DeliveryTruck
    get_default_opts: ->
        driver: null
        passenger: null
        drive_speed: 1
        capacity: 1

    constructor: (opts={}) ->
        @opts = _.extend @get_default_opts(), opts

        @driver = @opts.driver
        @passenger = @opts.passenger
        @drive_speed = @opts.drive_speed
        @capacity = @opts.capacity
        @storage = {}
        @total_stored = 0

        @state = new StateManager('idle')

    begin_loading: ->
        @state.change_state('loading')

    begin_unloading: ->
        @state.change_state('unloading')

    is_full: ->
        @total_stored == @capacity

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
        @state.current_state() == "parked"
