###
# Timer
# 
# Even though Timer is technically built to run like a StateObject, it is a prerequisite for
# StateObject so it cannot extend it. 
####

class Timer
  constructor: (@duration=0, @on_complete=null, @on_tick=null, @mode='manual')->
    @ticks = 0
    @timeout = null
    @state = new StateManager('init')
    @allow_auto_start = true
    @mode = @mode

  on: (what, fn) ->
    switch what
      when 'on_tick' then @on_tick = fn
      when 'complete' then @on_complete = fn
    
  start: (repeat=false, tick_every=1000) ->
    @state.change_state('running')

    if repeat
      clearTimeout(@timeout) if @timeout

      @timeout = setTimeout =>
        @update(true, tick_every)
      , tick_every

  pause: ->
    @state.change_state('paused')

  stop: ->
    @state.change_state('stopped')

  resume: ->
    @state.change_state('running')

  tick: ->
    @ticks += 1

    @on_tick?(@ticks)

    @finish() if @duration > 0 && @ticks > @duration

  update: ->
    @state.update()

    switch @state.current()
      when 'idle' then @start() if @allow_auto_start
      when 'reset' then @start()
      when 'running' then @tick()
      when 'stopped'
        clearTimeout(@timeout) if @timeout
        @reset()

  remaining: ->
    @duration - @ticks

  remaining_percent: ->
    (@duration - @ticks) / @duration

  percent_complete: ->
    #don't let this go over 100%
    Math.min 1, @ticks / @duration

  is_complete: ->
    # @state.current() == "complete"
    @ticks > @duration

  is_running: ->
    @state.current() == "running"

  finish: ->
    @on_complete?()
    @state.change_state('complete')

  reset: ->
    @ticks = 1
    @state.change_state('reset')

  set_duration: (new_dur, reset=false, mode=@mode) ->
    @duration = new_dur if new_dur > -1
    @set_mode mode if mode != @mode

    @reset() if reset

  set_mode: (mode) ->
    @mode = mode


World.Timer = Timer
