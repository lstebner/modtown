class Confirm extends FloatingMenu
  constructor: ->
    super

    @message = @opts.message
    @is_html = @opts.is_html

  default_opts: ->
    _.extend(
      super,
      title: 'Are you sure?'
      items: {
        yes: 'Ok'
        no: 'Cancel'
      }
      open: true
    )

  trigger: (event_name='item_selected', value) ->
    if event_name == 'item_selected'
      switch value
        when 'yes' then @confirm()
        when 'no' then @cancel()

      @destroy()

  confirm: ->
    @container.trigger('confirm')

  cancel: ->
    @container.trigger('cancel')


World.Confirm = Confirm
