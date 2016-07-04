class Alert
  constructor: (@message='', @type='status') ->
    @tmpl = _.template $('#alert-template').html()
    @dismissed = false

    @render()
    @setup_events()

    @

  delayed_dismiss: (millis=3000) ->
    setTimeout =>
      @dismiss()
    , millis

  setup_events: ->
    @container.on 'click', (e) =>
      e.preventDefault()
      $el = $(e.target)

      switch $el.data('action')
        when 'dismiss' then @dismiss()

  dismiss: ->
    return if @dismissed

    @dismissed = true
    @container.fadeOut ->
      $(this).remove()

  show: ->
    @container.fadeIn()

  render: ->
    data = 
      message: @message
      type: @type

    $alert = $ @tmpl data

    @container = $alert

    $('body').append @container
    @show()

World.Alert = Alert

class ErrorAlert extends Alert
  constructor: (@message='', @type='error') ->
    super @message, @type

    setTimeout =>
      @dismiss()
    , 1000*30

World.Alert.Error = ErrorAlert

class FundsNotAvailableAlert extends ErrorAlert
  constructor: (@message='Funds not available') ->
    super @message
