class Storage
    constructor: (@max_capacity=1) ->
        @num_stored_items = 0
        @items = {}

    get_items: ->
        @items

    is_empty: ->
        @num_stored_items == 0

    is_full: ->
        @num_stored_items == @max_capacity

    get_num_items: ->
        @num_stored_items

    over_capacity: ->
        @num_stored_items > @max_capacity

    get_num_items_by_type: (type) ->
        return -1 unless _.has @items, type

        @items[type]

    can_fit_items: (num_items=0) ->
        @num_stored_items + num_items < @max_capacity

    how_many_can_fit: (amount) ->
        fits = @max_capacity - @num_stored_items
        leftover = amount - fits

        [fits, leftover]

    # returns the amount of items that could *not* be stored
    # all_or_nothing flag will not store any if they don't all fit. When false, it will
    # store the max possible to fill up to max_capacity and return the amount
    # that it could not use
    store_items: (type, amount=1, all_or_nothing=true) ->
        @items[type] = 0 if !_.has @items, type
        return_amount = 0

        if @can_fit_items amount
            @items[type] += amount
        else if !all_or_nothing && @can_fit_items(1)
            [can_fit, remaining] = @how_many_can_fit(amount)
            @items[type] += can_fit
            return_amount = remaining
        else
            throw('Not enough room to store items')
            return_amount = amount

        @items_updated()

        return return_amount

    # this method will actually remove items from storage, if they're available
    remove_items: (type, amount=1) ->
        num_items = @get_num_items_by_type type

        if num_items < 0
            throw('Item not available in storage')
            return false

        else if num_items >= amount
            @items[type] -= amount
            console.log 'subtracted storage', @items[type], amount

        else if amount > num_items
            @items[type] = 0
            amount = num_items

        @items_updated()

        return amount

    retrieve_items: (type='all', amount=1) ->
        total_retrieved = 0
        retrieved_items = {}

        if type == 'all'
            types = @get_item_types()
            for type in types
                if total_retrieved < amount
                    retrieved_items[type] = @remove_items type, amount
                    total_retrieved += retrieved_items[type]
                else
                    break
        else
            retrieved_items[type] = @remove_items type, amount
            total_retrieved = retrieved_items[type]

        [retrieved_items, total_retrieved]

    items_updated: ->
        @num_stored_items = 0

        for key, items of @items
            @num_stored_items += items

        # @container.trigger('storage_updated')

        @num_stored_items

    get_item_types: ->
        _.keys @items

    take_items_from: (storage, type='all', amount=1) ->
        [items, total_amount] = storage.retrieve_items 'all', amount
        console.log 'retrieved items', items, total_amount
        for key, count of items
            @store_items key, count, false

        @items_updated()

    take_all_items_from: (storage, type='all') ->
        @take_items_from storage, type, @max_capacity








