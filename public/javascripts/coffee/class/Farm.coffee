# @codekit-prepend "Crop.coffee";

some_crops = 
  wheat:
    name: 'Wheat'
  potatos:
    name: 'Potatos'
  carrots: 
    name: 'Carrots'
  rice:
    name: 'Rice'
  grapes:
    name: 'Grapes'

some_crop_menu_items = {}
for key, crop of some_crops
  some_crop_menu_items[key] = crop.name

  some_crops[key] = new Crop null, _.extend(crop, { type: key })

class Structure.Farm extends Structure
  constructor: ->
    super

    @type = "farm"
    @available_crops = some_crops # @opts.available_crops
    @crop = @opts.crop
    @till_soil_time = WorldClock.duration .3, 'minutes'
    @harvest_time = 0
    @soil_ready = false
    @acres = 1 #1 acre in sq ft = 43560
    @crop_plots = 0
    @plots_per_acre = 0
    @current_growth_percent = 0
    @planted_crops = []
    @harvested_crops = []
    @last_harvest_amount = 0
    @state_timer = new Timer()

    @plots_available()
  
  default_opts: ->
    _.extend(
      super,
      name: 'Skillet Farms'
      construction_time: WorldClock.duration 5, 'seconds'
      crop: null
      available_crops: []
    )

  get_view_data: ->
    return super if @is_under_construction()

    percent_complete = if @state.current() == "growing"
      @current_growth_percent
    else
      @state_timer.percent_complete()

    _.extend(
      super,
      num_employees: @employees.length
      crop: @crop
      crop_state: @crop_state
      state: @state
      percent_complete: Math.min 100, Math.round(percent_complete * 100)
      soil_ready: @soil_ready
      harvested_crops: @harvested_crops
      planted_crops: @planted_crops
      crops_harvested: @last_harvest_amount
      crops_stored: @storage.get_num_items()
    )

  template_id: ->
    '#farm-template'

  settings_menu_items: ->
    view_info: 'Stats'
    change_crop: 'Change Crop'
    close: 'Close'

  begin_construction: ->
    @construction_time = WorldClock.duration(10, 'seconds')
    super

  setup_events: ->
    @container.on 'click', (e) =>
      e.preventDefault()
      $el = $(e.target)

      switch $el.data('action')
        when 'select_crop'
          select_crop_menu = new SelectCropMenu null, 
            open: true
            items: some_crop_menu_items
            position_for: [e.clientX, e.clientY]
          select_crop_menu.container.on 'item_selected', (e, value) =>
            if _.has @available_crops, value
              @set_crop @available_crops[value]

        when 'start_tilling' then @state.change_state('start_tilling')

  operating: (clock) ->
    super
    
    switch @state.current()
      #Structure triggers this one by default when construction completes
      when 'operating' then @state.change_state('idle')
      when 'idle' then @idle()
      when 'start_tilling' then @start_tilling()
      when 'tilling_soil' then @till_soil(clock)
      when 'planting' then @planting(clock)
      when 'growing' then @growing(clock)
      when 'harvest' then @harvest(clock)
      when 'reset' then @reset(clock)

  idle: ->

  can_change_crop: ->
    return @state.current() == "idle"

  crops_per_acre: ->
    return unless @crop

    # 43560 is the amount of real sq ft per acre. Not sure if that'll work
    # for our game though honestly
    @plots_per_acre = 10 / @crop.spacing
    @crop_plots = Math.floor(@plots_per_acre * @acres)
    @harvest_time = @crop_plots

    @plots_per_acre

  total_plots: ->
    Math.floor(@plots_per_acre * @acres)

  plots_available: ->
    @total_plots() - @planted_crops.length

  set_crop: (new_crop, start_planting=true) ->
    return unless @can_change_crop()

    @crop = new_crop
    @crops_per_acre()

    if start_planting
      if @state.current() != 'idle'
        @reset()
      else
        @start_tilling() 

  start_tilling: ->
    @state.change_state('tilling_soil')
    @state_timer.set_duration (@till_soil_time * (1 - @employees.length * .05)), true, "auto"

  till_soil: (clock) ->
    if @state_timer.is_complete()
      @start_planting()

  start_planting: ->
    @soil_ready = true
    @state.change_state('planting')
    @state_timer.set_duration @crop_plots, true, "manual"

  planting: (clock) ->
    return unless clock.is_afternoon() || Town.night_farming

    # Planting
    # Each plant requires a certain amount of time to be planted
    # The farm has a certain number of "plots" available to plant on
    # Planting is complete when every plot has a plant in it. 

    last = if @planted_crops.length
      @planted_crops.length - 1
    else
      false

    #if the last plant is not done planting yet then give it priority
    if last != false && !@planted_crops[last].fully_planted()
      @planted_crops[last].update(clock)

      if @planted_crops[last].fully_planted()
        @state_timer.update()
    #otherwise, start a new plant
    else if @planted_crops.length < @crop_plots
      new_plant = new Crop null, @available_crops[@crop.type]
      new_plant.start_planting()
      @planted_crops.push new_plant

    if @state_timer.is_complete()
      @finish_planting()

  #transition state
  finish_planting: (trigger_event='complete') ->
    @container.trigger("planting_#{trigger_event}") if trigger_event?
    @state.change_state('growing')
    @state_timer.set_duration @crop_plots, true, "manual"

  growing: (clock) ->
    total_growth_percent = 0

    for c in @planted_crops
      c.update(clock)
      total_growth_percent += c.current_growth_percent()

      if c.fully_grown()
        @state_timer.update()

    @current_growth_percent = total_growth_percent / @planted_crops.length

    if @state_timer.is_complete()
      @begin_harvest()

  begin_harvest: ->
    @state.change_state('harvest')
    @state_timer.set_duration @harvest_time, true, "manual"
    @last_harvest_amount = 0

  harvest: (clock) ->
    #once we run out of plots, we are done planting
    last = if @harvested_crops.length
      @harvested_crops.length - 1
    else
      false

    #if the last plant is not done planting yet then give it priority
    if last != false && !@harvested_crops[last].fully_harvested()
      @harvested_crops[last].update(clock)

      if @harvested_crops[last].fully_harvested()
        @state_timer.update()
        @last_harvest_amount += @harvested_crops[last].harvested_amount()

    #otherwise, start a new plant
    else if @planted_crops.length > 0
      next_plant = @planted_crops.shift()
      next_plant.start_harvest()
      @harvested_crops.push next_plant
    else if !@planted_crops.length && last && @harvested_crops[last].fully_harvested()
      console.log('Plant harvest count mismatch, finishing')
      while !@state_timer.is_complete()
        @state_timer.update(clock)

    if @state_timer.is_complete()
      @finish_harvest()

  finish_harvest: ->
    @last_harvest_amount = 0
    crop_type = @harvested_crops[0].type

    while crop = @harvested_crops.shift()
      @last_harvest_amount += crop.harvested_amount()

    couldnt_fit = @store_items crop_type, @last_harvest_amount, false

    if couldnt_fit > 0
      throw("Wasnt enough room to store #{couldnt_fit} Crops")

    @state.change_state('idle')

  reset: (clock) ->
    @state.change_state('idle')        
    @current_growth_percent = 0

  replant: ->
    @state.change_state('.planting')





