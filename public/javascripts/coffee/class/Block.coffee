class Block extends RenderedObject
    @costs: 
        excavation: 50
        housing: 14
        farm: 15
        factory: 25
        warehouse: 18

    constructor: ->
        super

        @type = ''
        @structure = null

        @update()

    update: (clock) -> 
        @structure.update(clock) if @structure

        @set_view_data 'block', { type: @type, structure: @structure }

    render: ->
        super

        @structure.render() if @structure

    build_structure: (type) ->
        switch type
            when 'housing' then @build_housing()
            when 'farm' then @build_farm()
            when 'factory' then @build_factory()
            when 'warehouse' then @build_warehouse()

        @container.find('.build_actions').remove()
        @container.find('.structure').show()

        @structure

    build_housing: ->
        @structure = new Housing @container.find('.structure')

    build_farm: ->
        @structure = new Farm @container.find('.structure')

    build_factory: ->
        @structure = new Factory @container.find('.structure')

    build_warehouse: ->
        @structure = new Warehouse @container.find('.structure')

    setup_events: ->
    

World.Block = Block
