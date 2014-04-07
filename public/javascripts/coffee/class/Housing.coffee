class Housing extends Structure
    constructor: ->
        super

        @max_occupants = 10
        @occupants = 0
        @rent_cost = 0
        @residents = []

    begin_construction: ->
        @construction_time = WorldClock.get_duration(10, 'seconds')
        super

    has_vacancy: ->
        @occupants < @max_occupants

    occupancy_percent: ->
        @occupants / @max_occupants

    vacancy_percent: ->
        (@max_occupants - @occupants) / @max_occupants

    move_resident_in: (resident) ->
        if @occupants == @max_occupants
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

    get_view_data: ->
        vdata = {}

        switch @state.current()
            when 'under_construction'
                vdata = super
            when 'operating'
                vdata = 
                    structure: @

        vdata

    template_id: ->
        '#housing-template'
