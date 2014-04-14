class ResidentMenu extends FloatingMenu
    constructor: ->
        super

        @resident = @opts.resident
        @set_title @resident.name
        @available_jobs = @opts.available_jobs

        @view_data = @get_view_data()

        @render(true)

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

    show_stats: ->

    assign_job: ->

    evict: ->
