class Housing extends Structure
    constructor: ->
        super

        @max_occupants = 10
        @occupants = 0
        @rent_cost = 0

    has_vacancy: ->
        (@occupants < @max_occupants)?

    move_resident_in: (resident) ->

    move_Resident_out: (resident) ->

    template_id: ->
        '#housing-template'
