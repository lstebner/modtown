class Town extends RenderedObject
    @costs: 
        street: 100
    @visitor_chance: .15

    default_opts: ->
        _.extend(
            super,
            balance: 0
        )

    constructor: ->
        super

        @street_tmpl = _.template $('#street-template').html()

        @location = [0, 0] #coordinate system
        @time = 0
        @day = 0
        @year = 0
        @balance = @opts.balance
        @spent = 0
        @occupancy_percent = 0

        @next_street_id = 0
        @next_resident_id = 0

        @streets = []
        @street_ids_to_index = {}
        @residents = []
        @resident_ids_to_index = {}
        @visitors = []
        @blocks = []
        @block_ids_to_index = {}
        @structures = []
        @structure_ids_to_index = {}
        @structures_by_type = {}

    template_id: ->
        '#town-template'

    render: ->
        super

        @render_streets()
        @render_visitors()

    update: (clock) ->
        for s in @streets
            s.update(clock)

        for r in @residents
            r.update(clock)

        @get_occupancy_percent()

        if @visitors.length < 12 && @occupancy_percent < .8 && clock.is_afternoon()
            if Math.random() < Town.visitor_chance
                @visitors.push @create_resident()

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

    render_streets: ->
        for s in @streets
            s.render()

    render_visitors: ->
        $visitors = @container.find('.visitors')

        if !@visitors.length
            $visitors.hide()
            return
        else if !$visitors.is(':visible')
            $visitors.show()

        visitors_tmpl = _.template $('#visitors-template').html()
        $visitors.empty()
        $visitors.html visitors_tmpl { visitors: @visitors }

    add_funds: (how_much=0) ->
        #todo: verify transaction?

        @balance += how_much

    spend_funds: (how_much=0) ->
        @spent += how_much
        @balance -= how_much

    funds_available: (how_much=0) ->
        (@balance - how_much) >= 0

    get_occupancy_percent: ->
        return unless _.has @structures_by_type, 'housing'
        structure_ids = @structures_by_type['housing']
        total = 0

        for idx in structure_ids
            total += @structures[idx]?.occupancy_percent()

        @occupancy_percent = total / structure_ids.length

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

        if !_.has @structures_by_type, type
            @structures_by_type[type] = []

        @structures_by_type[type].push(@structures.length - 1)

        new_structure

    setup_events: ->
        @container.on 'click', (e) =>
            e.preventDefault()
            $el = $(e.target)

            switch $el.data('action')
                when 'build_structure' then @build_structure $el.data('value'), $el.closest('.street').data('id'), $el.closest('.block').data('id')
                when 'add_block' then @create_block $el.closest('.street').data('id')
                when 'launch_build_menu' 
                    build_menu = new BuildMenu null, 
                        block_id: $el.closest('.block').data('id')
                        street_id: $el.closest('.street').data('id')
                        town: @
                        open: true

                    build_menu.best_position_for e.clientX, e.clientY

                    build_menu.container.one 'item_selected', (e, selection) =>
                        $el.hide()

