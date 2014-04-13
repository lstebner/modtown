# class Timer

Timers are used for tracking a set amount of time. In the game world, there are 2 different types of time and Timers can be used to track either. The first is real world time, tracked in milliseconds. These are Timers that use a timeout to "tick". The second type of timer is for tracking game ticks and typically these are attached toi game objects that go through the normal game update loop. These need to call `tick()` manually, but should be used for any events that track time in game so that they are kept up to date when time speeds up or frames are dropped.

## Properties

- ticks: default `0` | the current number of ticks on the timer
- duration: default `0` | the number of ticks when the timer will consider itself "complete". If left as 0, timer will never expire.
- on_complete: default `null` | callback for when the timer has completed
- on_tick: default `null` | callback to be called on every tick
- timeout: default `null` | a place to store a timeout reference if needed
- allow_auto_start: default `true` | this flag allows `update` to change states from "idle" to "running" automatically, without having to call `start()`. This really only affects the very first time that `update()` is called.
- state: StateManager object

## Methods

#### constructor (duration=0, on_complete=null, on_tick=null)

Initial constructor does not do anything except for store values. See Properties above for what these parameters are.

#### on (what, fn)

This method binds a callback to certain events. Timers currently support 2 events (use these as the `what` value): 
- `on_tick` - fired on every tick and passed the current tick number
- `complete` - fired when the timer has completed

Only one method can currently be bound to either event so calling `on` multiple times means that only the last bound event will actually be fired.

#### start (repeat=false, tick_every=1000) 

This method can be called to put the timer into "running" state, which means `update()` will then increment ticks on successive calls. This doesn't usually need to be called unless you want to use a timeout to repeat updates. 

If using a Timeout, then you should know that the Timer will be updated based on real world milliseconds. If you call the update method yourself, then you can update Timers based on actual game time progression. The latter is preferred if managing something in the game world, but if you want to use real world time then you can use the timeout functionality here.

It is important to call `reset()` instead of `start()` when you want to change an already expired timer because this method does not reset the value of `ticks`.

- repeat: default `false` | using a timeout to repeatedly tick.
- tick_every: default `1000` | how frequently to call tick if repeating, in milliseconds.

#### pause

Pause the timer from updating. Changes to state "paused".

#### stop

Similar to `pause`, this method stops ticking, changes the state to "stopped", but then the next update will also cause a `reset()` to happen.

#### resume

Changes the timer back to "running" state to continue ticking.

#### tick 

This method increments the number of ticks, calls the on_tick callback if there is one and checks if the timer has completed or not. Called automatically via `update` when the state is "running". Does not need to be called directly. Hook into the `on_tick` callback to have external objects update every tick. 

#### update

This method can handle updating the timer based on what state it is currently in. For the most part, unless the timer is "running" then nothing happens. This method should be called regularly during game update loops unless using the timeout functionality. 

Extend this in sub-classes to handle custom states or transitions.

#### remaining

The number of ticks remaining before this timer is "complete".

#### remaining_percent

The number of ticks remaining as a decimal. This will return a number between 0-1, you have to Round it and multiply by 100 for "nice" output.

#### percent_complete

The inverse of `remaining_percent()`.

#### is_complete

Check if the timer has completed or not

#### is_running

Check if the timer is currently running or not

#### finish

Triggered internally when the ticks have passed the duration. To hook into this method use `on` to bind an event to "complete".

#### reset 

Reset ticks and timer state back to default.

#### set_duration (new_dur, reset=false)

Change the timer duration value. If `reset` is false then the timer will continue ticking as normal. If the next tick is greater than the new duration it will complete on the next update, otherwise it will continue ticking as normal until it reaches this new duration.

If reset is true then the state and ticks will be reset as if a new timer was created with the new duration. The next `update` call will restart the ticking.






