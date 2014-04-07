# @codekit-append "Farm.coffee"
# @codekit-append "Factory.coffee"
# @codekit-append "Housing.coffee"

class Structure extends RenderedObject
    constructor: ->
        super

        @state = new StateManager 'idle'

        @type = ''
        @cost = 1
        @construction_time = @opts.construction_time
        @construction_time_remaining = 0
        @construction_started = null
        @construction_timer = null
        @built = false

        @construction_tmpl = _.template $('#structure-under-construction-template').html()

        @change_state('begin_construction') if @opts.begin_construction

    default_opts: ->
        _.extend(
            super,
            begin_construction: true
            construction_time: WorldClock.duration 1, 'minutes'
        )

    update: (clock) ->
        switch @state.current()
            when 'begin_construction' then @begin_construction(clock)
            when 'under_construction' then @progress_construction()
            when 'operating' then @operating()

        @state.update()

    progress_construction: ->
        return unless @construction_timer
        @construction_time_remaining = @construction_timer.remaining()
        # @construction_time_remaining = @construction_time - (Time.now() - @construction_started)

        # @finish_construction() if @construction_time_remaining < 0

    begin_construction: (clock) ->
        @change_state 'under_construction'

        @construction_timer = clock.create_timer @construction_time, =>
            @finish_construction()
        @construction_time_remaining = @construction_timer.remaining()
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
                    construction_time_remaining: @construction_timer.remaining()
                    construction_percent_complete: @construction_timer.remaining_percent()
                    construction_time_nice: moment.duration(@construction_time_remaining, 'milliseconds').humanize()

            else
                vdata = 
                    built: @built

        vdata

    operating: ->

    render: ->
        if @state.current() == "under_construction"
            @container.empty()
            @container.html @construction_tmpl @get_view_data()
        else
            super true
