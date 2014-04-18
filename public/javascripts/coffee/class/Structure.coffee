# @codekit-append "Farm.coffee"
# @codekit-append "Factory.coffee"
# @codekit-append "Housing.coffee"
# @codekit-append "Warehouse.coffee"

class Structure extends RenderedObject
    constructor: ->
        super

        @state = new StateManager 'idle'
        @state_timer = new Timer()

        @type = ''
        @cost = 1
        @construction_time = @opts.construction_time
        @construction_time_remaining = 0
        @construction_started = null
        @built = false
        @employees = @opts.employees
        @max_employees = @opts.max_employees
        @min_employees_to_operate = @opts.min_employees_to_operate
        @operating_cost = @opts.operating_cost
        @lifetime_operating_cost = 0

        @construction_tmpl = _.template $('#structure-under-construction-template').html()
        @needs_workers_tmpl = _.template $('#structure-needs-workers-template').html()

        @change_state('begin_construction') if @opts.begin_construction

    default_opts: ->
        _.extend(
            super,
            name: 'Structure'
            begin_construction: true
            construction_time: WorldClock.duration 1, 'minutes'
            employees: []
            max_employees: 5
            min_employees_to_operate: 1
            operating_cost: 10 #not yet implemented further than setting
        )

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            switch $el.data('action')
                when 'launch_settings_menu' then @open_settings_menu()

    setup_settings_menu: ->
        @settings_menu = new StructureMenu null,
            title: @name
            items:
                cancel: 'Close'

    open_settings_menu: ->
        return unless @settings_menu

        @settings_menu.open()

    update: (clock) ->
        @state.update(clock)

        switch @state.current()
            when 'begin_construction' then @begin_construction(clock)
            when 'under_construction' then @progress_construction(clock)
            when 'needs_workers' then @needs_workers()
            else 
                if @min_employees_to_operate > 0 && @employees.length < @min_employees_to_operate
                    return @state.change_state('needs_workers')
                
                @operating(clock)

    progress_construction: (clock) ->
        @state_timer.update()
        @construction_time_remaining = @state_timer.remaining
        @finish_construction() if @state_timer.is_complete()

    is_under_construction: ->
        @state.current() == 'under_construction' || @state.current() == "begin_construction"

    begin_construction: (clock) ->
        @change_state 'under_construction'

        @state_timer.set_duration @construction_time, true
        @construction_started = World.game.clock.now()
        @built = false

    finish_construction: ->
        @state.change_state('operating')
        @built = true

    employ_resident: (resident) ->
        return false if resident.is_employed() || @employees.length == @max_employees

        resident.set_employer @name
        @employees.push resident

    fire_resident: (id) ->
        remove_key = -1

        for r, key in @employees
            if r.id == id
                remove_key = key

        if remove_key > -1
            e = @employees.splice remove_key, 1
            e[0]?.set_employer null

    has_jobs_available: ->
        !!(@max_employees > 0 && @employees.length < @max_employees && !@is_under_construction())

    #meant to be overridden by subclasses
    settings_menu_items: ->
        close: 'Close'

    #meant to be subclasses as well for handling specific events
    settings_item_selected: (name) ->

    get_view_data: ->
        vdata = {}

        switch @state.current()
            when 'under_construction'
                vdata =
                    structure: null
                    construction_time: @construction_time
                    construction_time_remaining: @state_timer.remaining()
                    construction_percent_complete: @state_timer.percent_complete()
                    construction_time_nice: moment.duration(@construction_time_remaining, 'milliseconds').humanize()

            when 'needs_workers'
                vdata = 
                    built: @built
                    structure_id: @id
            else
                vdata = 
                    built: @built
                    structure: @

        vdata.state = @state
        vdata

    needs_workers: ->
        if @min_employees_to_operate == 0 || @employees.length >= @min_employees_to_operate
            @state.change_state('operating')

    operating: (clock) ->

    render: ->
        if @state.current() == "under_construction"
            @container.empty()
            @container.html @construction_tmpl(@get_view_data())
        else if @state.current() == "needs_workers"
            @container.empty()
            @container.html @needs_workers_tmpl @get_view_data()
        else
            super true
