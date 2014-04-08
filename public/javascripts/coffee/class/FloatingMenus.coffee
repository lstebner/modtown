class BuildMenu extends FloatingMenu
    constructor: ->
        super

        @block_id = @opts.block_id
        @street_id = @opts.street_id
        @town = @opts.town

    default_opts: ->
        _.extend(
            super,
            block_id: -1
            street_id: -1
            town: null
            title: 'Build Menu'
            items:
                build_farm: "Build Farm"
                build_factory: "Build Factory"
                build_housing: "Build Housing"
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

        @visitor = @opts.visitor
        @town = @opts.town
        @select_house_menu = null

    default_opts: ->
        _.extend(
            super,
            visitor: null
            town: null
            title: 'Visitor Actions'
            items: 
                move_in: "Move In"
                kick_out: "Kick Out"
        )

    trigger: (event_name='item_selected', value=null) ->
        super

        if event_name == 'item_selected'
            switch value
                when 'move_in' then @move_in_to_town()
                when 'kick_out' then @kick_out_of_town()

        @destroy()

    move_in_to_town: ->
        return unless @town && @visitor

        @select_house_menu = new SelectHouseMenu null, 
            town: @town
            visitor: @visitor
            open: true

    kick_out_of_town: ->
        return unless @town && @visitor

        @town.remove_visitor @visitor.id

class SelectHouseMenu extends FloatingMenu
    constructor: ->
        super

        @town = @opts.town
        @visitor = @opts.visitor

    default_opts: ->
        _.extend(
            super,
            town: null
            visitor: null
            title: 'Select Home'
        )



