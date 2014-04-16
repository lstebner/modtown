class HireWorkersMenu extends FloatingMenu
    constructor: ->
        super

        @workers = @opts.workers
        @job = @opts.job

        @setup_items()

    setup_items: ->
        items = {}

        for w in @workers
            items[w.id] = w.name

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
            @assign_worker_to_job parseInt value

    assign_worker_to_job: (worker_id) ->
        return unless @job

        worker = null
        for w in @workers
            worker = w if w.id = worker_id

        return unless worker

        @job.employ_resident worker
        @destroy()

    render: ->
        if @items?
            @message = if _.isEmpty @items
                'No Workers Available'
            else
                ''

        super
