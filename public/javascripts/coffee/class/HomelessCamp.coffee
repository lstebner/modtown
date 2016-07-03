class Structure.HomelessCamp extends Structure.Housing
  constructor: ->
    super
    
    @type = "homeless_camp"

  default_opts: ->
    _.extend(
      super,
      name: "Homeless Camp"
    )

