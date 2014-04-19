class StateObject
    constructor: ->
        @state = new StateManager('idle')
        @state_timer = new Timer()

    update: ->
        @state.update()
        @state_timer.update()
