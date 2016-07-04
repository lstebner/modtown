class Block extends RenderedObject
  @allowed_structures: [
    "excavation", "housing", "farm", "factory", "warehouse",
    "construction_office", "homeless_camp"
  ]

  @get_structure_cost: (type="default") ->
    if Structure.costs.hasOwnProperty(type)
      Structure.costs[type]
    else
      Structure.costs.default

  template_id: ->
    "#block-template"

  constructor: ->
    super

    @structure = null
    @settings_link = @container.find('[data-action=launch_settings_menu]')
    @settings_menu = null

    @setup_settings_menu()
    @update()

  update: (clock) -> 
    @structure.update(clock) if @structure

    # @set_view_data 'block', { id: @id, type: @type, structure: @structure }

  get_view_data: ->
    _.extend(
      super,
      id: @id
      structure: @structure
      type: @type
      is_vacant: @is_vacant()
    )

  render: ->
    super

    @settings_link = @container.find('[data-action=launch_settings_menu]')

    if @structure != null
      @structure.render()
      @settings_link.text @structure.name

  is_vacant: ->
    @structure == null

  build_structure: (type, address=null, additional_opts={}) ->
    structure_class = switch type
      when 'housing' then Structure.Housing
      when 'farm' then Structure.Farm
      when 'factory' then Structure.Factory
      when 'warehouse' then Structure.Warehouse
      when 'construction_office' then Structure.ConstructionOffice
      when 'homeless_camp' then Structure.HomelessCamp
      else null

    return console.error("failed to find class for #{type}") if structure_class == null

    structure_opts = _.extend
      address: address
      , additional_opts

    @structure = new structure_class @container.find(".structure"), structure_opts

    #ui updates
    @container.find('.build_actions').remove()
    @settings_link.text(@structure.name)

    @container.find('.structure').data('id', @structure.id).show()
    @setup_settings_menu()

    # todo: shouldn't this be happening with render automatically? 
    @container.find(".build_btn").hide()

    @type = type
    @structure

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
