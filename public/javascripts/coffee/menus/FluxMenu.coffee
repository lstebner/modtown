class FluxMenu extends FloatingMenu
  constructor: ->
    super

    @clock = @opts.clock

    @set_position 10, 10

  default_opts: ->
    _.extend(
      super,
      title: 'Flux Menu'
      clock: new WorldClock()
      items:
        pause_time: 'Pause Time'
        resume_time: 'Resume Time'
        speed_up_time: 'Speed up Time'
        slow_down_time: 'Slow Down Time'
        default_time: 'Reset Time Speed'
        add_one_hour: 'Add 1 Hour'
    )

  trigger: (event_name='item_selected', value) ->
    if event_name == 'item_selected'
      switch value
        when 'pause_time' then @pause_time()
        when 'resume_time' then @resume_time()
        when 'speed_up_time' then @speed_up_time()
        when 'slow_down_time' then @slow_down_time()
        when 'default_time' then @default_time()
        when 'add_one_hour' then @add_one_hour()

  add_one_hour: ->
    @clock?.add_time 1, 'hours'

  pause_time: ->
    @clock?.pause_time()

  resume_time: ->
    @clock?.resume_time()

  speed_up_time: ->
    @clock?.time_speed_plus()

  slow_down_time: ->
    @clock?.time_speed_minus()

  default_time: ->
    @clock?.time_speed_default()

World.FluxMenu = FluxMenu

