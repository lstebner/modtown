class Street extends RenderedObject
    constructor: ->
        super

        @state = new StateManager 'setup'

        @block_tmpl = _.template $('#block-template').html()

        @name = ''
        @num_blocks = 0
        @max_blocks = 6

        @next_block_id = 0
        @blocks = []
        @block_ids_to_index = {}
        @structures = []
        @structure_ids_to_index = {}

    setup_blocks: ->
        for i in [1..@opts.blocks]
            @create_block()

        @num_blocks = @blocks.length

    render: ->
        super

        for b in @blocks
            b.render()

    update: (clock) ->
        switch @state.current()
            when 'setup'
                @setup_blocks()
                @state.change_state 'running'

            when 'running'
                for b in @blocks
                    b.update(clock)

        @state.update()

    _block_id: ->
        @next_block_id += 1

    _block_props: (props={}) ->
        _.extend
            id: @_block_id()
        , props

    create_block: (props={}) ->
        return unless @num_blocks < @max_blocks

        props = @_block_props props
        $new_block = $('<div/>').addClass('block').attr('data-id', props.id)
        @container.find('.blocks').append($new_block)
        new_block = new Block @container.find(".block[data-id=#{props.id}]"), props
        @blocks.push new_block
        @block_ids_to_index[new_block.id] = @blocks.length - 1

        @num_blocks = @blocks.length

    build_structure: (type, build_id) ->
        if !_.has @block_ids_to_index, build_id
            return throw('Bad block id')

        block_idx = @block_ids_to_index[build_id]
        new_structure = @blocks[block_idx].build_structure type
        @structures.push new_structure
        @structure_ids_to_index[new_structure.id] = @structures.length - 1
        new_structure

    setup_events: ->
        # @container.on 'click', '.btn', (e) =>
        #     e.preventDefault()
        #     $el = $(e.target)

        #     switch $el.data('action')
        #         when 'add_block' then @create_block()
