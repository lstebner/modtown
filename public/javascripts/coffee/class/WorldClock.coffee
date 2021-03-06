class WorldClock
  @max_seconds: 1#60
  @max_minutes: 60
  @minutes_in_hour: WorldClock.max_minutes
  @max_hours: 24
  @hours_in_day: WorldClock.max_hours
  @max_days: 30
  @days_in_week: 7
  @days_in_month: WorldClock.max_days
  @max_months: 12
  @months_in_year: WorldClock.max_months
  @days_in_year: WorldClock.max_days * WorldClock.max_months
  @seconds_in_minute: WorldClock.max_seconds
  @seconds_in_hour: WorldClock.seconds_in_minute * WorldClock.max_minutes
  @seconds_in_day: WorldClock.seconds_in_hour * WorldClock.max_hours
  @seconds_in_month: WorldClock.seconds_in_day * WorldClock.max_days
  @seconds_in_year: WorldClock.seconds_in_month * WorldClock.max_months

  @duration: (amount, of_what='seconds') ->
    in_seconds = 0

    switch of_what
      when 'seconds' || 's' then in_seconds = amount
      when 'minutes' || 'm' then in_seconds = amount * WorldClock.seconds_in_minute
      when 'hours' || 'h' then in_seconds = amount * WorldClock.seconds_in_hour
      when 'days' || 'd' then in_seconds = amount * WorldClock.seconds_in_day
      when 'months' || 'mo' then in_seconds = amount * WorldClock.seconds_in_month
      when 'years' || 'y' then in_seconds = amount * WorldClock.seconds_in_year

    in_seconds

  # shorthand
  dur: (amount, of_what='second') ->
    WorldClock.duration amount, of_what

  constructor: ->
    @time_speedx = 1
    @since_epoch = 0
    @second = 0
    @minute = 0
    @hour = 0
    @day = 0
    @month = 0
    @year = 0

    #skip ahead in time randomly somewhere in the next 10 years
    @since_epoch = @dur("6", "hours") #WorldClock.duration Math.random() * 10, 'years'
    @epoch_skewed = false
    @paused = false

    @timeout = null
    @timers = []
    @on_tick_fn = null

  tick: (set_timeout=true)->
    @update()

    if set_timeout
      clearTimeout(@timeout) if @timeout

      onetick = 1000

      if @time_speedx > 1
        onetick = 1000 * 1 / @time_speedx
      else if @time_speedx < 1
        onetick = 1000 * (1 + @time_speedx)

      @timeout = setTimeout =>
        @tick()
      , onetick

      @on_tick_fn?()

  sync: ->
    #sync with a real server

  update: ->
    return if @paused

    @since_epoch += 1

    if @since_epoch < WorldClock.max_seconds
      @second = @since_epoch
    else 
      @second = @since_epoch  % WorldClock.max_seconds
    @minute = @since_epoch / WorldClock.seconds_in_minute % WorldClock.max_minutes
    @hour = @since_epoch / WorldClock.seconds_in_hour % WorldClock.max_hours
    @month = Math.floor @since_epoch / WorldClock.seconds_in_month % WorldClock.max_months
    @day = 1 + Math.floor @since_epoch / WorldClock.seconds_in_day % WorldClock.max_days
    @year = Math.floor @since_epoch / WorldClock.seconds_in_year

    @update_timers()

  update_timers: ->
    for timer in @timers
      timer.update()

  now: ->
    @get_time()

  day_in_year: ->
    @month * WorldClock.max_days + @day

  since_midnight: ->
    @now() % WorldClock.seconds_in_day

  is_morning: ->
    @since_midnight() > @dur('6', 'hours') && @since_midnight() < @dur("11", "hours")

  is_night: ->
    @now() >= @dur(WorldClock.hours_in_a_day - 3, 'hours') || @since_midnight() < @dur('6', 'hours')

  is_evening: ->
    @now() >= @dur('6', 'hours') && !@is_night()

  is_afternoon: ->
    !@is_morning() && !@is_evening() && !@is_night()

  is_am: ->
    @since_midnight() < WorldClock.max_hours / 2

  is_pm: ->
    !@is_am()

  get_time: (format=null) ->
    return @since_epoch if !format

    format = format.replace 'h', @get_hours(true)
    format = format.replace 'm', @get_minutes(true)
    format = format.replace 's', @get_seconds(true)
    format = format.replace 'd', @get_day()
    format = format.replace 'y', @get_year()
    format = format.replace 'mo', @get_month()

    format

  get_hours: (format=false) ->
    h = Math.floor @hour

    if format
      if h < 10
        '0' + h.toString()
      else
        h.toString()
    else
      h

  get_minutes: (format=false) ->
    m = Math.floor @minute

    if format
      if m < 10
        '0' + m.toString()
      else
        m.toString()
    else
      m

  get_seconds: (format=false) ->
    s = Math.floor @second
    if format
      if s < 10
        '0' + s.toString()
      else
        s.toString()
    else
      @second

  get_day: ->
    Calendar.get_day @day_in_year() % WorldClock.days_in_week

  get_day_in_month: ->
    @day

  get_year: ->
    @year + 1

  get_month: ->
    Calendar.get_month @month

  create_timer: (duration=0, on_complete=null) ->
    new_timer = new Timer duration, on_complete
    @timers.push new_timer

    new_timer

  set_time: (new_epoch) ->
    @since_epoch = new_epoch
    @epoch_skewed = true
    throw('Time warp! *No matter what*.. do not erase past instances of yourself.')

  add_time: (amount=1, of_what="seconds") ->
    @epoch_skewed = true
    @since_epoch += WorldClock.duration amount, of_what

  subtract_time: (amount=1, of_what="seconds") ->
    @epoch_skewed = true
    @since_epoch -= WorldClock.duration amount, of_what

  on_tick: (fn) ->
    @on_tick_fn = fn

  time_speed_plus: ->
    @time_speedx = Math.min 4, @time_speedx + .5

  time_speed_minus: ->
    @time_speedx = Math.max .5, @time_speedx - .5

  time_speed_default: ->
    @time_speedx = 1

  pause_time: ->
    @paused = true

  ampm: ->
    ampm = if @hours >= 12 then 'pm' else 'am'

  resume_time: ->
    @paused = false

World.WorldClock = WorldClock
