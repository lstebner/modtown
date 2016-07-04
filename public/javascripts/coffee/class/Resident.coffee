class Resident extends RenderedObject
  @male_names: ['Sonny', 'Art', 'Brett', 'Perry', 'Humberto', 'Carmine', 'Bernard', 'Myles', 'Frances', 'Octavio', 'Edmundo', 'Alan', 'Leland', 'Derek', 'Jamaal', 'Cecil', 'Kenton', 'Elwood', 'Buford', 'Mac']
  @female_names: ['Celinda' ,'Robena' ,'Bonita' ,'Katy' ,'Esmeralda' ,'Danae' ,'Rena' ,'Amberly' ,'Tillie' ,'Emily' ,'Margareta' ,'Shenita' ,'Lavon' ,'Willene' ,'Felisha' ,'Joaquina' ,'Regine' ,'Sheena' ,'Denice' ,'Rona']
  @gender_weight_male: .65
  @random_name: (gender='male') ->
    name = if gender == 'male'
      @male_names[Math.floor(Math.random() * Resident.male_names.length)]
    else
      @female_names[Math.floor(Math.random() * Resident.female_names.length)]

    name

  constructor: ->
    super

    @state = new StateManager('idle')

    @house = @opts.house
    @house_id = @house?.id

    @employer = @opts.employer
    @role = null

    @setup_stats()

  setup_stats: ->
    @gender = if Math.random() > Resident.gender_weight_male
      'female'
    else
      'male'

    @name = Resident.random_name(@gender)

    @sleep_schedule = 
      goto_bed: WorldClock.duration('9', 'hours')
      wake_up: WorldClock.duration('2', 'hours')

    @work_schedule = 
      goto_work: WorldClock.duration('4', 'hours')
      leave_work: WorldClock.duration('7', 'hours')

  default_opts: ->
    _.extend(
      super,
      house: null
      employer: null
    )

  update: (clock) ->
    @state.update()

    switch @state.current()
      when 'goto_bed' then @change_state('sleeping')
      when 'sleeping' then @sleep(clock)
      when 'wake_up' then @change_state('idle')
      when 'goto_work' then @change_state('working')
      when 'working' then @work(clock)
      when 'idle' then @idle(clock)

  render: ->
    #do nothing right now

  sleep: (clock) ->
    now = clock.since_midnight()

    if now > @sleep_schedule.wake_up && clock.is_morning()
      @change_state('wake_up')

  work: (clock) ->
    now = clock.since_midnight()

    if !@is_employed() || now > @work_schedule.leave_work
      @change_state('idle')

  idle: (clock) ->
    now = clock.since_midnight()

    if now > @sleep_schedule.goto_bed || now < @sleep_schedule.wake_up
      @change_state('goto_bed')
    else if @employer && now > @work_schedule.goto_work
      @change_state('goto_work')

  is_employed: ->
    @employer != null

  set_employer: (employer) ->
    @employer = employer

  assign_role: (role, force=false) ->
    #todo: consider disallowing role change when state == "sleeping"

    if @role != null && !force
      throw('Resident already has role')
      return @
    else
      @container.trigger('role_changed')

      @role = role
      @

  release_role: ->
    @role = null



World.Resident = Resident
