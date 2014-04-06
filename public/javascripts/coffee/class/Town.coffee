class Town extends RenderedObject
    @costs: 
        street: 100

    default_opts: ->
        _.extend
            balance: 0
        , super

    constructor: ->
        super

        @street_tmpl = _.template $('#street-template').html()

        @location = [0, 0] #coordinate system
        @time = 0
        @day = 0
        @year = 0
        @balance = @opts.balance
        @spent = 0

        @next_street_id = 0
        @next_resident_id = 0

        @streets = []
        @street_ids_to_index = {}
        @residents = []
        @resident_ids_to_index = {}
        @blocks = []
        @block_ids_to_index = {}
        @structures = []
        @structure_ids_to_index = {}

    template_id: ->
        '#town-template'

    render: ->
        super

        @render_streets()

    update: ->
        for s in @streets
            s.update()

    _street_id: ->
        @next_street_id += 1

    _street_props: (props={}) ->
        _.extend
            id: @_street_id()
            name: 'One Street'
        , props

    create_street: (props={}) ->
        if !@funds_available(Town.costs.street)
            new FundsNotAvailableAlert()
            throw('Funds not available')
            return false

        @spend_funds Town.costs.street


        props = @_street_props props

        $new_street = $ @street_tmpl({ id: props.id })
        @container.find('.streets').append($new_street)
        new_street = new Street @container.find(".street[data-id=#{props.id}]"), props
        @streets.push new_street

        @street_ids_to_index[new_street.id] = @streets.length - 1

    create_block: (street_id, props={}) ->
        street_idx = @street_ids_to_index[street_id]
        street = @streets[street_idx]

        return unless street

        if !@funds_available(Block.costs.excavation)
            new FundsNotAvailableAlert()
            return throw('Funds not available')

        @spend_funds Block.costs.excavation

        new_block = street.create_block props
        @blocks.push new_block
        @block_ids_to_index[new_block.id] = @blocks.length - 1

    _resident_id: ->
        @next_resident_id += 1

    _resident_props: (props={}) ->
        _.extend
            id: @_resident_id()
            name: 'Mr Resident'
        , props

    create_resident: (props={}) ->
        props = @_resident_props props
        new_resident = new Resident null, props
        @residents.push new_resident

    render_streets: ->
        for s in @streets
            s.render()

    add_funds: (how_much=0) ->
        #todo: verify transaction?

        @balance += how_much

    spend_funds: (how_much=0) ->
        @spent += how_much
        @balance -= how_much

    funds_available: (how_much=0) ->
        (@balance - how_much) >= 0

    build_structure: (type, street_id, block_id) ->
        if !_.has(Block.costs, type)
            return throw('Bad type')
        if !@funds_available(Block.costs[type])
            new FundsNotAvailableAlert()
            return throw('Funds not available')

        @spend_funds Block.costs[type]

        street_id = @street_ids_to_index[street_id]

        return unless _.has @streets, street_id 
        new_structure = @streets[street_id].build_structure(type, block_id)

        if !new_structure
            return throw('Error creating structure')

        @structures.push(new_structure)
        @structure_ids_to_index[new_structure.id] = @structures.length - 1

        new_structure

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            switch $el.data('action')
                when 'build_structure' then @build_structure $el.data('value'), $el.closest('.street').data('id'), $el.closest('.block').data('id')
                when 'add_block' then @create_block $el.closest('.street').data('id')

