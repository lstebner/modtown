class Farm extends Structure
    begin_construction: ->
        @construction_time = Time.in_millis 5, 'minutes'

        super

    template_id: ->
        '#farm-template'
