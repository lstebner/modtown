class Block extends RenderedObject
    @costs: 
        excavation: 50
        housing: 4
        farm: 5
        factory: 5
    constructor: ->
        super

        @type = ''
        @structure = null

        @update()

    update: -> 
        @structure.update() if @structure

        @set_view_data 'block', { type: @type, structure: @structure }

    render: ->
        super

        @structure.render() if @structure

    build_structure: (type) ->
        switch type
            when 'housing' then @build_housing()
            when 'farm' then @build_farm()
            when 'factory' then @build_factory()

        @container.find('.build_actions').remove()
        @container.find('.structure').show()

        @structure

    build_housing: ->
        @structure = new Housing @container.find('.structure')

    build_farm: ->
        @structure = new Farm @container.find('.structure')

    build_factory: ->
        @structure = new Factory @container.find('.structure')

    setup_events: ->
    #     @container.on 'click', (e) =>
    #         e.preventDefault()
    #         $el = $(e.target)

    #         switch $el.data('action')
    #             when 'build_structure' then @build_structure $el.data('value')

World.Block = Block
