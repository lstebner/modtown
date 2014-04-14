class VisitorMenu extends FloatingMenu
    constructor: ->
        super

        @visitor = @opts.visitor
        @town = @opts.town
        @housing = @town.get_housing()

        @setup_house_menu()

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

    setup_house_menu: ->
        @select_house_menu = new SelectHouseMenu null, 
            housing: @housing

    trigger: (event_name='item_selected', value=null) ->
        super

        if event_name == 'item_selected'
            switch value
                when 'move_in' then @move_in_to_town()
                when 'kick_out' then @kick_out_of_town()

        @destroy()

    move_in_to_town: ->
        return unless @town && @visitor

        @select_house_menu.open()

        @select_house_menu.container.one 'house_selected', (e, house_id) =>
            house_id = parseInt house_id.replace("house_", "")
            for house in @housing
                if house.id == house_id
                    @town.convert_visitor_to_resident @visitor.id
                    house.move_resident_in @visitor


    kick_out_of_town: ->
        return unless @town && @visitor

        @town.remove_visitor @visitor.id
