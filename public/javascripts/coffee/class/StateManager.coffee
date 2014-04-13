class StateManager
    constructor: (state='', duration=0, queue_state='') ->
        @default_state = state
        @current_state = state
        @next_state = ''
        @previous_state = ''

        @state_changed_at = 0
        @time_since_change = 0

        @duration = duration
        @ticks = 0
        @queued_state = queue_state

        @bindings = {}
        @history = []

    time_since_state_change: ->
        @time_since_change

    current: ->
        @current_state

    on: (event_name, fn, overwrite=false) ->
        if !_.has(@bindings, event_name) || overwrite
            @bindings[event_name] = []

        @bindings[event_name].push fn

    queue_state: (state='', change_in=0) ->
        @queued_state = state

        if change_in > 0
            @duration = change_in 
            @ticks = 0

    change_state: (new_state='', duration=0, queue_state='') ->
        return if new_state == @current_state

        @next_state = new_state
        @record_history 'next'

        if duration > 0
            @queue_state queue_state, duration

    trigger: (event_name, data=null) ->
        return unless _.has @bindings, event_name

        for fn in @bindings[event_name]
            fn.apply @, data?

    record_history: (type='changed') ->
        switch type
            when 'changed'
                @history.push
                    the_time: (new Date()).getTime()
                    current_state: @current_state
                    previous_state: @previous_state

            when 'next'
                @history.push
                    the_time: (new Date()).getTime()
                    current_state: @current_state
                    next_state: @next_state

    update: (clock=null) ->
        @ticks += 1
        @time_since_change = clock.now() - @state_changed_at if clock

        if @duration && @ticks > @duration && !_.isEmpty(@queued_state)
            @change_state @queued_state
            @queued_state = ''
            @duration = 0

        return if _.isEmpty(@next_state)

        @previous_state = @current_state
        @current_state = @next_state
        @next_state = ''

        @state_changed_at = clock.now() if clock

        @trigger 'state_changed', [@current_state, @previous_state]
        @record_history 'changed'
