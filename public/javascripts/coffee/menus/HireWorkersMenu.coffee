class HireWorkersMenu extends FloatingMenu
  @outsource_hire_cost: 45

  constructor: ->
    super

    @workers = @opts.workers
    @job = @opts.job
    @funds_available = @opts.funds_available

    @setup_items()

  setup_items: ->
    items = {}

    if @workers.length
      for w in @workers
        items[w.id] = w.name
    else
      items["outsource_hire"] = "Outsource Hire $#{HireWorkersMenu.outsource_hire_cost}"

    @set_items items

  default_opts: ->
    _.extend(
      super,
      title: "Hire Workers"
      workers: []
      job: null
    )

  trigger: (event_name='item_selected', value) ->
    if event_name == 'item_selected'
      if value == "outsource_hire"
        @outsource_hire()
      # default tries to use value as worker ID to hire
      else
        @assign_worker_to_job parseInt value

  assign_worker_to_job: (worker_id) ->
    return unless @job

    worker = null
    for w in @workers
      worker = w if w.id = worker_id

    return unless worker

    @job.employ_resident worker
    @destroy()

  outsource_hire: ->
    return unless @funds_available - HireWorkersMenu.outsource_hire_cost > 0
    @container.trigger "hire:outsource_hire", HireWorkersMenu.outsource_hire_cost 
    @destroy()

  render: ->
    if @items?
      @message = if _.isEmpty @items
        'No Workers Available'
      else
        ''

    super
