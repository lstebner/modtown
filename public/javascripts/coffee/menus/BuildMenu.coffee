class BuildMenu extends FloatingMenu
  constructor: ->
    super

    @block_id = @opts.block_id
    @street_id = @opts.street_id
    @town = @opts.town

  default_opts: ->
    _.extend(
      super,
      block_id: -1
      street_id: -1
      town: null
      title: 'Build Menu'
      items:
        build_construction_office: "Build Construction Office"
        build_farm: "Build Farm"
        build_factory: "Build Factory"
        build_housing: "Build Housing"
        build_warehoue: "Build Warehouse"
    )


  trigger: (event_name='item_selected', value) ->
    super

    if @town && event_name == 'item_selected'
      build_what = value.substring(value.indexOf("_") + 1)
      result = @town.build_structure build_what, @street_id, @block_id
      # todo: handle some error scenarios

      @destroy() 
