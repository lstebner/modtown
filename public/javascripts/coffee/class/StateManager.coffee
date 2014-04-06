class StateManager
    constructor: (state='') ->
        @current_state = state
        @next_state = ''
        @previous_state = ''

        @bindings = {}
        @history = []

    current: ->
        @current_state

    on: (event_name, fn, overwrite=false) ->
        if !_.has(@bindings, event_name) || overwrite
            @bindings[event_name] = []

        @bindings[event_name].push fn

    change_state: (new_state='') ->
        @next_state = new_state
        @record_history 'next'

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

    update: ->
        return if _.isEmpty(@next_state)

        @previous_state = @current_state
        @current_state = @next_state
        @next_state = ''

        @trigger 'state_changed', [@current_state, @previous_state]
        @record_history 'changed'
