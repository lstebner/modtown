class SelectCropMenu extends FloatingMenu
  constructor: ->
    super

    @crops = @opts.crops

    @view_data = @get_view_data()

    @render(true)

  default_opts: ->
    _.extend(
      super,
      title: 'Select Crop'
      items: []
    )

  trigger: ->
    super

    @destroy()
