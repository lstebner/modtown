# class WorldClock

## Description

This class is responsible for keeping track of the time in the world. It should never be reset once a game begins, but it can be paused to state save the world. Ideally, every town would sync with a server world clock, but each town will probably have its own clock to begin with. 

## Use

Creating a clock is easy. The `tick` method needs to be called one time and by default will then infinitely track time. There are several helpful getter methods for fetching the time when needed. Any in game items should use the world time to track progress of events. See the Calendar class for several predetermined time-based events.

```javascript
gossipStone = new WorldClock()
gossipStone.tick()
```

## Rules of Times

Time is tracked similarly to real world ("meat space") time, but is significantly sped up in terms of days. 

Rules
- 1 second = 1 second
- 1 minute = 60 seconds
- 1 hour = 60 minutes
- 1 day = 10 hours
- 1 month = 30 days
- 1 year = 16 months

## Static Properties

- double_time: this flag says whether to run the game in super sped up time (10x) or normal time (1x). It's mainly for debugging clock stuff.
- max_seconds: `60` | The number of seconds in a minute
- max_minutes: `60` | The number of minutes in an hour
- max_hours: `10` | The number of hours in a day
- max_days: `30` | The number of days in a month
- max_months: `16` | The number of months in a year
- seconds_in_minute: Calculated number of seconds that make up one minute
- seconds_in_hour: Calculated number of seconds that make up one hour
- seconds_in_day: Calculated number of seconds that make up one day
- seconds_in_month: Calculated number of seconds that make up one month
- seconds_in_year: Calculated number of seconds that make up one_year

## Properties

- since_epoch: default `0` | The number of seconds since the beginning of time (deeeeep).
- second: default `0` | The current second of the tick
- minute: default `0` | The current minute of the tick
- hour: default `0` | The current hour of the tick
- day: default `0` | The current day of the tick
- month: default `0` | The current month of the tick
- year: default `0` | The current year of the tick
- timeout: default `null` | The timeout for ticking
- timers: default `[]` | Any active timers the clock is currently managing

## Static Methods

#### duration (amount, of_what='seconds')

Get a duration of time from the World Clock. This is important to use when setting Timer's so that they tick in relation to world time (which can be sped up or slowed down this way).

- amount: The int value of whatever your duration is
- of_what: default `seconds` | The metric you're trying to get

This method takes `amount` and multipies it by the `WorldClock.seconds_in_[of_what]` where `of_what` is what you pass. 

## Methods

#### constructor

Sets up all the default values, nothing special to see here. Note that it does *not* start ticking. You must call `tick()` yourself.

#### tick (set_timeout=true)

This method calls `update` to increment time. It's most useful with `set_timeout` flagged as true in order to repeatedly track time on its own. 

- set_timeout: default `true` | If true then the clock will internally use timeouts to tick, if passed as false you must call tick manually to increase time.

#### sync

Sync with the global time server. Not implemented!

#### update

This method is called by tick to increment time and update all related values to "now". Does not need to be called externally.

This method automatically calls `update_timers()`.

#### now

Convenience method for the number of ticks that represent now.

#### get_time (format=null)

Get the current time. If `format` is left null then you get back the raw time since the epoch in seconds, otherwise you'll get a formatted string. 

- format: default `null` | If a string is passed containing certain characters they will be replaced with the values that represent "now". 

The following characters can be used:
- h: hour
- m: minute
- s: second
- d: day
- y: year
- mo: month

Example:

```javascript
gossipStone = new WorldClock()
gossipStone.tick()
gossipStone.get_time('mo d, y h:m:s')
```

#### get_hours (format=false)

Get the current 'hour' value. Use the `format` flag to get a string instead of the raw number.

- format: default `false` | If `false` the hour integer will be returned; if `true` then the hour will be formatted as a string which includes a leading zero.

#### get_minutes (format=false)

Get the current 'minute' value. Use the `format` flag to get a string instead of the raw number.

- format: default `false` | If `false` the minute integer will be returned; if `true` then the minute will be formatted as a string which includes a leading zero.

#### get_seconds (format=false)

Get the current 'second' value. Use the `format` flag to get a string instead of the raw number.

- format: default `false` | If `false` the second integer will be returned; if `true` then the second will be formatted as a string which includes a leading zero.

#### get_day

Get the current day of the week as a string.

#### get_year

Get the current year as a 1-based value. 

#### get_month

Get the current month as a string. 

#### create_timer (duration=0, on_complete=null)

Creates a new timer which will automatically be ticked on update. You should pass `on_complete` as a method to be called when the timer goes off, though the new timer is also returned.

- duration: default `0` | How long the timer should last. Use the `WorldClock.duration` static method to get an accurate value. 
- on_complete: default `null` | A callback method for when the timer goes off.
