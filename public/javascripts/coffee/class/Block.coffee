class Block extends RenderedObject
    @costs: 
        excavation: 50
        housing: 14
        farm: 15
        factory: 25
        warehouse: 18

    template_id: ->
        "#block-template"

    constructor: ->
        super

        @type = ''
        @structure = null
        @settings_link = @container.find('[data-action=launch_settings_menu]')
        @settings_menu = null

        @setup_settings_menu()
        @update()

    update: (clock) -> 
        @structure.update(clock) if @structure

        # @set_view_data 'block', { id: @id, type: @type, structure: @structure }

    get_view_data: ->
        id: @id
        structure: @structure
        type: @type

    render: ->
        super

        @settings_link = @container.find('[data-action=launch_settings_menu]')

        if @structure != null
            @structure.render()
            @settings_link.text @structure.name

    build_structure: (type) ->
        switch type
            when 'housing' then @build_housing()
            when 'farm' then @build_farm()
            when 'factory' then @build_factory()
            when 'warehouse' then @build_warehouse()

        #ui updates
        @container.find('.build_actions').remove()
        @settings_link.text(@structure.name)

        @container.find('.structure').show()
        @setup_settings_menu()

        @structure

    build_housing: ->
        @structure = new Housing @container.find('.structure')

    build_farm: ->
        @structure = new Farm @container.find('.structure')

    build_factory: ->
        @structure = new Factory @container.find('.structure')

    build_warehouse: ->
        @structure = new Warehouse @container.find('.structure')

    settings_menu_items: ->
        if @structure
            @structure.settings_menu_items()
        else
            close: 'Close'

    setup_settings_menu: ->
        @settings_menu.destroy() if @settings_menu

        @settings_menu = new StructureMenu null,
            title: if @structure then @structure.name else "Block #{@id}"
            items: @settings_menu_items()

        @settings_menu.container.on 'item_selected', (e, value) =>
            @settings_item_selected value

    launch_settings_menu: ->
        if !@settings_menu
            @setup_settings_menu()

        @settings_menu.open()

    settings_item_selected: (name) ->
        @structure.settings_item_selected(name) if @structure

        switch (name)
            when 'close' then @settings_menu.close()

        #todo: consider always closing when an item is selected

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            switch $el.data('action')
                when 'launch_settings_menu' then @launch_settings_menu()
    

World.Block = Block
