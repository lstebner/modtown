# class StateManager

The purpose of this class is to manage the changing of states. The problem with changing a state "at will" is that a change could happen mid update (in between two objects reading data and making state-based decisions) and cause odd behaviour. Using this class to change_states at a regular scheduled update will make sure everything is in sync.

## Properties

- default_state: default `''` | not used for anything currently, but is set to the initial state given
- current_state: default `''` | the current state 
- next_state: default `''` | the next state the manager will change to during the next update
- previous_state: default `''` | the last state the manager was in
- duration: default '0' | states can be queued 1 level deep to change after a set duration, this is that duration. This will be set by the `queue_state` method.
- ticks: default `0` | also goes along with state queueing, this is the timer to count up to the duration. 
- queued_state: default `''` | the name of the state to queue up. See `queue_state` method
- bindings: default `{}` | the manager uses this to bind events to callbacks. It doesn't need to be touched :)
- history: default `[]` | the manager will keep track of the history of state changes and store them here. 
- state_changed_at: default `0` | stores the time at which states are changed if update is given a clock
- time_since_change: default `0` | computed time since the last state change if update is given a clock

## Methods

#### constructor (state, duration=0, queue_state='')

Sets up initial properties and can also queue up an automatic state change. See the `queue_state` method for more information on how queueing. 

- state: what to set the current state to
- duration: default `0` | how long this state should last before changing to the queued state. If left as 0, no state will be queued.
- queue_state: default `''` | the state to change to after the duration expires. If left empty, no state will be queued.

#### time_since_state_change 

Returns the amount of time since the states were last changed.

#### current ()

Get the name of the current state. No parameters needed.

#### on (event_name, fn, overwrite)

Bind a callback to an event.

- event_name: the name of the event to bind the callback to
- fn: the function to call when the event is fired
- overwrite: default `false` | pass this flag to clear any existing bindings to this event.
- this method is used to set up an event binding based on events that the StateManager will naturally fire. See the *events* section below for more info on events. All events are fired in the context of the StateManager and are passed `current_state` and `previous_state`. 
- It's important to notice there can be multiple bindings to a single event. If you want to overwrite them, be sure to pass the `overwrite` flag.

#### queue_state (state='', change_in=0)

Queue a state to change to automatically after a certain number of ticks. A "tick" is a call to `update`. Only one state can be queued and the last set state is the one that will be used when the duration expires. 

If `change_in` is left as 0, the `ticks` value will not be reset, but the new state will still be queued. This means that you can use this method as a reset by providing a new duration, or simply provide a new state to change what is queued without affecting when it will be fired.

- state: default `''` | the name of the state to change to after the specified duration
- change_in: default `0` | the duration to wait before changing to the queued state. If this is left as 0, ticks will not be reset, but the new state will still be set as the `queued_state`.

#### change_state (new_state) 

Change to a new state.

- new_state: the new state to change to during the next update
- this method should always be used to change states instead of accessing the states directly. It will set up the `next_state` which will then trigger the `state_changed` event.

#### trigger (event_name, data)

Internally used method for trigger events. To bind to events use the `on` method.

- event_name: the event to be triggered
- data: default `null` | any data to be passed to the binded callback method (if there is any)
- this is an internal method to trigger events so that they can be binded to
- record_history: (type)
- type: default `changed` | the type of history to be recorded
- this is an internal method that is used for creating a history (or "log") of when events happened. Current events include when a state is staged for change ('next') and when a change has actually occurred ('changed'). 

#### update (clock=null)

This method should be called regularly to get states in sync as expected. It should be called either before or after an objects logic is ran. Whichever you decide to do, be consistent! If you are not, then some objects may end up changing state while others are still relying on them to be in another state and this will cause weird sync issues between game objects. 

The reason the `clock` is optionally is because the state manager doesn't really care about time. However, if you give it access to the time then it will capture when states change and you can use this information to determine the amount of real time spent inside of a state.


## Events

- state_changed: this event is fired when a state change occurs 
