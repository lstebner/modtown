class SelectJobMenu extends FloatingMenu
  constructor: ->
    super

    @resident = @opts.resident
    @jobs = @opts.jobs

  default_opts: ->
    _.extend(
      super,
      name: 'Select Job'
      jobs: null
      resident: null
    )
