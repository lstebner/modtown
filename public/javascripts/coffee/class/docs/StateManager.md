# class StateManager

The purpose of this class is to manage the changing of states. The problem with changing a state "at will" is that a change could happen mid update (in between two objects reading data and making state-based decisions) and cause odd behaviour. Using this class to change_states at a regular scheduled update will make sure everything is in sync.

## Properties

- current_state: default `''` | the current state 
- next_state: default `''` | the next state the manager will change to during the next update
- previous_state: default `''` | the last state the manager was in
- bindings: default `{}` | the manager uses this to bind events to callbacks. It doesn't need to be touched :)
- history: default `[]` | the manager will keep track of the history of state changes and store them here. 

## Methods

- constructor: (state)
    - state: what to set the current state to
- current: 
    - accessor to get the current_state
- on: (event_name, fn, overwrite)
    - event_name: the name of the event to bind the callback to
    - fn: the function to call when the event is fired
    - overwrite: default `false` | pass this flag to clear any existing bindings to this event.
    - this method is used to set up an event binding based on events that the StateManager will naturally fire. See the *events* section below for more info on events. All events are fired in the context of the StateManager and are passed `current_state` and `previous_state`. 
    - It's important to notice there can be multiple bindings to a single event. If you want to overwrite them, be sure to pass the `overwrite` flag.
- change_state: (new_state) 
    - new_state: the new state to change to during the next update
    - this method should always be used to change states instead of accessing the states directly. It will set up the `next_state` which will then trigger the `state_changed` event.
- trigger: (event_name, data)
    - event_name: the event to be triggered
    - data: default `null` | any data to be passed to the binded callback method (if there is any)
    - this is an internal method to trigger events so that they can be binded to
- record_history: (type)
    - type: default `changed` | the type of history to be recorded
    - this is an internal method that is used for creating a history (or "log") of when events happened. Current events include when a state is staged for change ('next') and when a change has actually occurred ('changed'). 
- update:
    - this method should be called regularly before or after (be consistent!) whatever state-based object is using this. 

## Events

- state_changed: this event is fired when a state change occurs 
