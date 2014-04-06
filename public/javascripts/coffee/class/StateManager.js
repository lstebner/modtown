class StateManager
    constructor: (state, states)
        @all_states = states
        @current_state = state
        @next_state = ''
        @previous_state = ''
