class Structure.ConstructionOffice extends Structure
  template_id: ->
    '#construction-office-template'

  default_opts: ->
    _.extend(
      super,
      min_employees_to_operate: 3
    )
