class Town extends RenderedObject
  @costs: 
    street: 100
  @extra_visitors: true
  @visitor_chance: if Town.extra_visitors then .15 else .05
  @no_visitors_at_night: false 
  @night_farming: true
  @max_visitors = 12

  default_opts: ->
    _.extend(
      super,
      balance: 0
    )

  constructor: ->
    super

    @street_tmpl = _.template $('#street-template').html()

    @location = [0, 0] #coordinate system
    @time = 0
    @day = 0
    @year = 0
    @balance = @opts.balance
    @spent = 0
    @occupancy_percent = 0
    @is_night = false

    @next_street_id = 0
    @next_resident_id = 0

    @streets = []
    @street_ids_to_index = {}
    @residents = []
    @resident_ids_to_index = {}
    @visitors = []
    @selected_visitor = 0
    @blocks = []
    @block_ids_to_index = {}
    @structures = []
    @structure_ids_to_index = {}
    @structures_by_type = {}

  template_id: ->
    '#town-template'

  render: ->
    super

    @render_streets()
    @render_visitors()

  update: (clock) ->
    @is_night = clock.is_night()

    for s in @streets
      s.update(clock)

    for r in @residents
      r.update(clock)

    @get_occupancy_percent()

    @update_visitors(clock)

  get_view_data: ->
    {
      is_night: @is_night
    }

  update_visitors: (clock) ->
    return unless @meets_minimum_reqs_for_visitors()

    alter_chance = 1

    if @visitors.length >= Town.max_visitors
      alter_chance = -1
    else if @is_night
      if Town.no_visitors_at_night
        alter_chance = -1
      else
        alter_chance = .5
    else if clock.is_afternoon()
      alter_chance += .05

    if @occupancy_percent < .2
      alter_chance += .1
    else if @occupancy_percent > .85
      alter_chance -= .1

    visitor_chance = if alter_chance
      Town.visitor_chance * alter_chance
    else
      Town.visitor_chance

    die_roll = Math.random() * 100

    if die_roll < visitor_chance * 80
      @create_visitor()

  meets_minimum_reqs_for_visitors: ->
    reqs_met = false

    # gather data
    num_construction_offices = @num_structures_in_town "construction_office"
    num_housing = @num_structures_in_town "housing"

    # decide if reqs are met
    reqs_met = num_construction_offices > 0 && num_housing > 0
    reqs_met

  num_structures_in_town: (only_type=false) ->
    count = 0
    for street in @streets
      count += street.num_structures_on_street only_type

    count

  get_structures: (only_type=false) ->
    structures = []
    for street in @streets
      structs = street.get_structures only_type
      unless _.isEmpty(structs)
        for s in structs
          structures.push(s) 

    structures

  find_housing_with_vacancy: (amount=-1) ->
    housing = @get_structures "housing"

    housing_with_vacancy = for h in housing
      h if h.has_vacancy()

    if amount < 0
      housing
    else if amount == 1
      housing[0]
    else
      _.first housing, amount

  _street_id: ->
    @next_street_id += 1

  _street_props: (props={}) ->
    _.extend
      id: @_street_id()
      name: 'One Street'
    , props

  create_street: (props={}) ->
    if !@funds_available(Town.costs.street)
      new FundsNotAvailableAlert()
      console.error('Funds not available')
      return false

    @spend_funds Town.costs.street

    props = @_street_props props

    $new_street = $ @street_tmpl({ id: props.id, editable: false })
    @container.find('.streets').append($new_street)
    new_street = new Street @container.find(".street[data-id=#{props.id}]"), props
    @streets.push new_street

    @street_ids_to_index[new_street.id] = @streets.length - 1

  create_block: (street_id, props={}) ->
    street_idx = @street_ids_to_index[street_id]
    street = @streets[street_idx]

    return unless street

    excavation_cost = Block.get_structure_cost("excavation")

    if !@funds_available excavation_cost
      new FundsNotAvailableAlert()
      return console.error('Funds not available')

    @spend_funds excavation_cost

    new_block = street.create_block props
    @blocks.push new_block
    @block_ids_to_index[new_block.id] = @blocks.length - 1

  _resident_id: ->
    @next_resident_id += 1

  _resident_props: (props={}) ->
    _.extend
      id: @_resident_id()
      name: 'Mr Resident'
    , props

  #get a visitor
  #by default just looks up by index, but if `is_id` is
  #passed as true, it looks up by id property
  get_visitor: (id=0, is_id=false) ->
    if is_id
      for v in @visitors
        if v.id == id
          return v
    else
      if _.has @visitors, id
        @visitors[id]
      else
        false

  create_visitor: (props={}) ->
    props = @_resident_props props
    new_resident = new Resident null, props
    @visitors.push new_resident

    new_resident

  remove_visitor: (id) ->
    visitors_cleaned = []

    for v in @visitors
      visitors_cleaned.push(v) if v.id != id

    @visitors = visitors_cleaned

  convert_visitor_to_resident: (visitor_id) ->
    visitor = @get_visitor visitor_id, true
    return unless visitor

    @residents.push visitor
    @resident_ids_to_index[visitor.id] = @residents.length - 1
    @remove_visitor visitor_id
    visitor

  get_resident: (id) ->
    if !_.has @resident_ids_to_index, id
      console.error('resident ID not found')
      return false

    @residents[@resident_ids_to_index[id]]

  render_streets: ->
    for s in @streets
      s.render()

  render_visitors: ->
    $visitors = @container.find('.visitors')

    if !@visitors.length
      $visitors.hide()
      return
    else if !$visitors.is(':visible')
      $visitors.show()

    visitors_tmpl = _.template $('#visitors-template').html()
    $visitors.empty()
    $visitors.html visitors_tmpl { visitors: @visitors, selected_visitor: @selected_visitor }

  add_funds: (how_much=0) ->
    #todo: verify transaction?

    @balance += how_much

  spend_funds: (how_much=0) ->
    @spent += how_much
    @balance -= how_much

  funds_available: (how_much=0) ->
    (@balance - how_much) >= 0

  get_occupancy_percent: ->
    return unless _.has @structures_by_type, 'housing'
    structure_ids = @structures_by_type['housing']
    total = 0

    for idx in structure_ids
      total += @structures[idx]?.occupancy_percent()

    @occupancy_percent = total / structure_ids.length

  build_structure: (type, street_id, block_id) ->
    if _.indexOf(Block.allowed_structures, type) < 0
      return console.error('Bad type')

    block_cost = Block.get_structure_cost type
    if !@funds_available block_cost
      new FundsNotAvailableAlert()
      return console.error('Funds not available')

    @spend_funds block_cost

    street_id = @street_ids_to_index[street_id]

    return unless _.has @streets, street_id 
    new_structure = @streets[street_id].build_structure(type, block_id)

    if !new_structure
      return console.error('Error creating structure')

    @structures.push(new_structure)
    @structure_ids_to_index[new_structure.id] = @structures.length - 1

    if !_.has @structures_by_type, type
      @structures_by_type[type] = []

    @structures_by_type[type].push(@structures.length - 1)

    # todo: create requirements for structures to be created and
    # return errors here when they aren't met

    new_structure

  setup_events: ->
    @container.on 'click', (e) =>
      e.preventDefault()
      $el = $(e.target)

      switch $el.data('action')
        when 'build_structure' then @build_structure $el.data('value'), $el.closest('.street').data('id'), $el.closest('.block').data('id')
        when 'add_block' then @create_block $el.closest('.street').data('id')
        when 'launch_build_menu' 
          build_menu = new BuildMenu null, 
            block_id: $el.closest('.block').data('id')
            street_id: $el.closest('.street').data('id')
            town: @
            open: true

          build_menu.best_position_for e.clientX, e.clientY

          build_menu.container.one 'item_selected', (e, selection) =>
            $el.hide()

        when 'launch_visitor_menu'
          $el.addClass('active')
          @selected_visitor = $el.data('index')
          visitor_menu = new VisitorMenu null,
            town: @
            visitor: @get_visitor $el.data('index'), false
            open: true

          visitor_menu.best_position_for e.clientX, e.clientY

          visitor_menu.container.one 'destroy', =>
            @selected_visitor = null

        when 'launch_resident_menu'
          resident = @get_resident $el.data('id')
          resident_menu = new ResidentMenu null, 
            resident: resident
            available_jobs: @get_available_jobs()
            open: true

        when 'launch_hire_workers_menu'
          structure_id = $el.data('structure-id')
          if _.has @structure_ids_to_index, structure_id
            structure = @get_structure structure_id
            if structure
              hire_workers_menu = new HireWorkersMenu null, 
                job: structure
                workers: @get_available_workers()
                open: true
                position_for: [e.clientX, e.clientY]
                funds_available: @balance

              hire_workers_menu.container.one "hire:outsource_hire", (e, cost) =>
                @outsource_hire(cost, hire_workers_menu.job)

        when 'request_warehouse_pickup'
          structure_id = $el.closest('.structure').data('id')
          structure = @get_structure structure_id
          
          console.log "request warehouse pickup", structure, _.has(@structures_by_type, 'warehouse')
          if structure && _.has(@structures_by_type, 'warehouse')
            warehouse = @structures[_.first @structures_by_type['warehouse']]
            warehouse.queue_pickup structure


  get_structure: (id) ->
    return false if !_.has @structure_ids_to_index, id

    @structures[@structure_ids_to_index[id]]

  get_housing: (only_vacant=false) ->
    return unless _.has @structures_by_type, 'housing'
    housing = @structures_by_type['housing']
    results = []

    for h in housing
      s = @structures[h]
      results.push(s) if !only_vacant || s.has_vacancy()

    results

  get_available_jobs: ->
    jobs = []
    for s in @structures
      jobs.push(s) if s.has_jobs_available()

    jobs

  get_available_workers: ->
    workers = []
    for r in @residents
      workers.push(r) if !r.is_employed()

    workers

  get_vacant_blocks: ->
    vacancies = []
    for street in @streets
      for block in street.blocks
        if block.is_vacant()
          vacancies.push [street.id, block.id]
    vacancies

  outsource_hire: (cost, job) ->
    if !@funds_available cost
      return console.error "not enough funds to outsource hire" 

    @spend_funds cost

    newhire = @create_visitor()
    @convert_visitor_to_resident newhire.id
    new_home = @find_home()
    new_home.move_resident_in newhire
    job.employ_resident newhire
    console.log "outsource resident moved in and hired"

    newhire

  build_homeless_camp: ->
    vacancies = @get_vacant_blocks()
    console.error "no vacancies!" unless vacancies.length
    @build_structure "homeless_camp", vacancies[0][0], vacancies[0][1]
    
  find_home: ->
    num_housing = @num_structures_in_town "housing"
    homeless_camps = @get_structures "homeless_camp"

    chosen_home = if num_housing < 1
      if _.isEmpty(homeless_camps)
        @build_homeless_camp()
      else
        homeless_camps[0]
    else
      @find_housing_with_vacancy(1)

    chosen_home





