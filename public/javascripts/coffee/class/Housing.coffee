_house_ids = "abcdefghijklmnopqrstuvwxyz"
_house_idx = 0
_next_house_name = ->
  letter = _house_ids[_house_idx % _house_ids.length]
  letters = ""
  for i in [0...(Math.floor(_house_idx / _house_ids.length) + 1)]
    letters += letter

  _house_idx += 1

  "Housing Complex #{letters.toUpperCase()}"

class Structure.Housing extends Structure
  constructor: ->
    super

    @type = "housing"
    @max_occupants = 12
    @occupants = 0
    @rent_cost = 0
    @residents = []

  default_opts: ->
    _.extend(
      super,
      name: _next_house_name()
      min_employees_to_operate: 0
    )

  settings_menu_items: ->
    view_info: 'Stats'
    view_occupants: 'Occupants'
    destroy: 'Destroy'
    close: 'Close'

  has_vacancy: ->
    !@is_under_construction() && @occupants < @max_occupants

  occupancy_percent: ->
    @occupants / @max_occupants

  vacancy_percent: ->
    (@max_occupants - @occupants) / @max_occupants

  begin_construction: ->
    @construction_time = WorldClock.duration(.10, 'minutes')
    super

  move_resident_in: (resident) ->
    if @occupants == @max_occupants
      new ErrorAlert('No vacancy!').delayed_dismiss()
      return throw('Max occupants in housing')

    @occupants += 1
    @residents.push resident

  move_resident_out: (resident) ->
    return if @occupants == 0
    @occupants -= 1

    residents_new = []
    for r in @residents
      if resident.id != r.id
        residents_new.push r

    @residents = residents_new

  get_resident: (id) ->
    found = null

    for r in @residents
      found = r if r.id = id

    found

  get_view_data: ->
    return super if @is_under_construction() || !@built

    vdata = 
      structure: @
      occupants: @residents

  template_id: ->
    '#housing-template'
