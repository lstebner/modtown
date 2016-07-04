class StateObject
  constructor: ->
    @bindings = {}
    @state = new StateManager('idle')
    @state_timer = new Timer()

  update: ->
    @state.update()
    @state_timer.update() if @state_timer.mode == "auto"

  on: (event_name, fn, overwrite=false) ->
    if !_.has(@bindings, event_name) || overwrite
      @bindings[event_name] = []

    @bindings[event_name].push fn

  off: (event_name, fn, destroy_all=false) ->
    if _.has(@bindings, event_name)
      if destroy_all
        delete @bindings[event_name]
      else
        for func, i in @bindings[event_name]
          if func.toString() == fn.toString()
            delete @bindings[event_name][i]

  trigger: (event_name, data=null) ->
    return unless _.has @bindings, event_name

    for fn in @bindings[event_name]
      fn?.apply @, data
