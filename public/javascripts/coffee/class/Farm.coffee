class Farm extends Structure
    begin_construction: ->
        @construction_time = WorldClock.duration 5, 'minutes'

        super

    template_id: ->
        '#farm-template'
