# class Structure extends RenderedObject

A Structure is generally anything that can be built onto a Block. They often employ Residents or provide places to Work and Shop, but it's up to you!

## Author

- by Luke
- last updated 4-13-2014

## Properties

- state: a StateManager object, used for tracking the state of the Structure. Structure itself implements many default states, but sub-classes are meant to implement their own more specific ones.
- state_timer: a Timer object. This can be used to keep track of durations for knowing when to change states. For example, construction time.
- type: default `''` | A type to give the Structure
- cost: default `1` | A cost to give the Structure for initial purchase
- construction_time: default `1m` | The amount of time in game world ticks to complete construction
- construction_time_remaining: default `0` | convenient accessor to the amount of time remaining during construction phase.
- construction_started: default `null` | although this defaults to null, after construction has started it becomes set to the time that construction began at.
- built: default `false` | a flag to say whether the Structure has been completely built or not
- employees: default `[]` | the employees for the Structure. There is no default way to set employees later so you must implement that in your own classes if your Structure can employ Residents.
- max_employees: default `5` | the maximum number of employees you want to allow at this Structure
- operating_cost: default `5` | the recurring cost to run this Structure
- lifetime_operating_cost: default `0` | a total of all operating_cost charges to this Structure over its lifetime.
- construction_tmpl: default "#structure-under-construction-template" | this is used for rendering the under construction state.

## Methods

#### constructor (container, opts)

Sets up all default options and begins construction if requested. Available options include:

```javascript
default_opts = {
    super,
    begin_construction: true,
    construction_time: WorldClock.duration(1, 'minutes'),
    employees: [],
    max_employees: 5,
    operating_costs: 10
}
```

#### update (clock)

Called regularly on world ticks to update the Structure. This base class is meant to be subclassed, but by default implements the states "begin_construction", "under_construction" and "operating". Once a Structure is "operating" your subclass should pick up and take over. See Examples at the bottom.

#### begin_construction (clock)

Changes Structure to "under_construction" state and sets up `state_timer`. 

#### progress_construction (clock)

Called during the "under_construction" state to continue construction. 

#### finish_construction ()

Called once to mark construction completed. This changes the Structure to the state "operating".

#### is_under_construction ()

A way to check if the Structure is currently under construction or not

#### operating (clock)

Operating is a special method/state because the Structure will go in to the state "operating" as soon as construction completes, but will also continue to call this method during all update ticks as long as it is not in a construction state.

What this means is when you sublcass Structure to build your own Structure types, you should use this method and treat it like the `update` method however it will not be called until construction is completed. See the Examples below.

#### render

Render is meant to be sublcassed, but make sure to call up to it so that construction can be handled automatically. If you want to use a different construction template then consider setting `construction_tmpl` in the constructor instead of trying to override the render for it here.

## Examples

#### Generic Instance

```javascript
myStructure = new Structure({
    type: 'building',
    construction_time: WorldClock.duration(1, 'hours'),
    operating_cost: 50
    begin_construction: true
})
```
