class FloatingMenu extends Popup
  constructor: ->
    super

    @set_items @opts.items

  default_opts: ->
    _.extend(
      super,
      message: ''
      items: []
      body_template: '#floating-menu-template'
    )
  
  get_view_data: ->
    _.extend(
      super,
      items: @items
    )

  set_items: (new_items) ->
    @items = new_items
    @set_view_data 'items', @items
    @render(true)
    @container.trigger('items_changed')

  setup_events: ->
    super

    @container.on 'item_selected', (e, value) =>
      @item_selected value

    @container.on 'click', (e) =>
      $el = $(e.target)

      if $el.is('.btn')
        @trigger 'item_selected', $el.data('action')

  item_selected: (value) ->
    switch value
      when 'close' then @close()
      


World.FloatingMenu = FloatingMenu
