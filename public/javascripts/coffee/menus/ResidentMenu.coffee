class ResidentMenu extends FloatingMenu
  constructor: ->
    super

    @resident = @opts.resident
    @set_title @resident.name
    @available_jobs = @opts.available_jobs
    @job_ids_to_index = {}

    @view_data = @get_view_data()

    @render(true)

    @jobs_menu = null
    @setup_jobs_menu()

  destroy: ->
    @jobs_menu.destroy() if @jobs_menu

    super

  default_opts: ->
    _.extend(
      super,
      resident: null
      items: 
        show_stats: 'Show Stats'
        assign_job: 'Assign Job'
        evict: 'Evict'
      available_jobs: []
    )

  trigger: (event_name='item_selected', value) ->
    if event_name == "item_selected"
      switch value
        when 'show_stats' then @show_stats()
        when 'assign_job' then @assign_job()
        when 'evict' then @evict()

  setup_jobs_menu: ->
    job_items = {}

    for job, i in @available_jobs
      job_items[job.id] = job.name
      @job_ids_to_index[job.id] = i

    @jobs_menu = new SelectJobMenu null, { items: job_items }

    @jobs_menu.container.on 'item_selected', (e, value) =>
      job_id = parseInt value

      if _.has @job_ids_to_index, job_id
        job = @available_jobs[@job_ids_to_index[job_id]]
        job.employ_resident @resident

      @destroy()

  show_stats: ->

  assign_job: ->
    @jobs_menu.open()

  evict: ->
