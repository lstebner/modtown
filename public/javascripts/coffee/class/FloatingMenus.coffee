class BuildMenu extends FloatingMenu
    constructor: ->
        super

        @block_id = @opts.block_id
        @street_id = @opts.street_id
        @town = @opts.town

    default_opts: ->
        _.extend(
            super,
            {
                block_id: -1
                street_id: -1
                town: null
                title: 'Build Menu'
                items:
                    build_farm: "Build Farm"
                    build_factory: "Build Factory"
                    build_housing: "Build Housing"
            }
        )


    trigger: (event_name='item_selected', value) ->
        super

        if @town && event_name == 'item_selected'
            switch value
                when 'build_farm' then @town.build_structure 'farm', @street_id, @block_id
                when 'build_factory' then @town.build_structure 'factory', @street_id, @block_id
                when 'build_housing' then @town.build_structure 'housing', @street_id, @block_id

            @destroy()

class VisitorMenu extends FloatingMenu
    constructor: ->
        super

    default_opts: ->
        _.extend(
            super,
            {
                title: 'Visitor Actions'
                items: 
                    move_in: "Move In"
                    kick_out: "Kick Out"
            }
        )
