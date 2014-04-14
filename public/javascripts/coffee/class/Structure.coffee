# @codekit-append "Farm.coffee"
# @codekit-append "Factory.coffee"
# @codekit-append "Housing.coffee"

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
        @operating_cost = @opts.operating_cost
        @lifetime_operating_cost = 0

        @construction_tmpl = _.template $('#structure-under-construction-template').html()

        @change_state('begin_construction') if @opts.begin_construction

    default_opts: ->
        _.extend(
            super,
            begin_construction: true
            construction_time: WorldClock.duration 1, 'minutes'
            employees: []
            max_employees: 5
            operating_cost: 10 #not yet implemented further than setting
        )

    update: (clock) ->
        @state.update(clock)

        switch @state.current()
            when 'begin_construction' then @begin_construction(clock)
            when 'under_construction' then @progress_construction(clock)
            else @operating(clock)

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

    get_view_data: ->
        vdata = {}

        switch @state.current()
            when 'under_construction'
                vdata =
                    construction_time: @construction_time
                    construction_time_remaining: @state_timer.remaining()
                    construction_percent_complete: @state_timer.percent_complete()
                    construction_time_nice: moment.duration(@construction_time_remaining, 'milliseconds').humanize()

            else
                vdata = 
                    built: @built

        vdata

    operating: (clock) ->

    render: ->
        if @state.current() == "under_construction"
            @container.empty()
            @container.html @construction_tmpl @get_view_data()
        else
            super true
