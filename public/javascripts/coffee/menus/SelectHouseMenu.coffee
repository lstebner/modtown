class SelectHouseMenu extends FloatingMenu
    constructor: ->
        super

        @housing = @opts.housing

        @setup_items()

    setup_items: ->
        return unless @housing

        @items = {}

        for house in @housing
            @items["house_#{house.id}"] = house.name

        @render(true)

    default_opts: ->
        _.extend(
            super,
            title: 'Select Home'
            housing: []
        )

    trigger: (event_name='item_selected', value=null) ->
        super

        if event_name == 'item_selected'
            @trigger 'house_selected', value

        @destroy()
