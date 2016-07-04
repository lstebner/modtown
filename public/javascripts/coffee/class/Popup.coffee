class Popup extends RenderedObject
  @Create: (opts={}) ->
    opts = _.extend { open:true }, opts
    new Popup null, opts

  @CreateModal: (opts={}) ->
    opts = _.extend { open:true, is_modal:true }, opts
    new Popup null, opts

  constructor: (container, opts={}) ->
    super

    if !@container.length
      @container = $('<div/>').addClass('popup')
      $('body').append @container.hide()

    @title = @opts.title
    @message = @opts.message
    @is_modal = @opts.is_modal
    @set_body_template @opts.body_template
    @classes = @opts.classes
    @classes.push('wide') if @opts.wide

    @default_position = @container.position()

    @setup_events()

    @render(true)

    if @opts.position_for.length > 1
      @best_position_for @opts.position_for[0], @opts.position_for[1]
    else
      @set_position_in_window @opts.position_in_window

    @open() if @opts.open

  default_opts: ->
    _.extend(
      super,
      title: 'Popup Item'
      body_template: null
      open: false
      message: ''
      is_modal: false
      position_for: []
      position_in_window: 'center'
      classes: []
      wide: false
    )
    
  template_id: ->
    '#popup-template'

  setup_events: ->
    return unless @container.length

    @container.on 'click', (e) =>
      e.preventDefault()

      $el = $(e.target)

      if $el.is('[data-action=cancel]')
        @close()
        return @trigger 'cancel'

  set_body_template: (template_id=null, render=false) ->
    return unless template_id

    if !$(template_id).length
      throw("Body Template #{template_id} not found")

    @body_template = _.template $("#{template_id}").html()

    @render(true) if render

  get_view_data: ->
    _.extend(
      super,
      title: @title
      message: @message
    )

  #close the menu
  close: ->
    if @is_modal
      World.window_overlay.hide()

    @container.hide().trigger('close')

  hide: ->
    @close()

  #open the menu
  open: ->
    if @is_modal
      World.window_overlay.show()

    @render(true)
    @container.show().trigger('open')

  show: ->
    @open()

  #close, unbind and remove the menu
  destroy: ->
    if @is_modal
      World.window_overlay.hide()

    @container.trigger('destroy').hide()
    @container.unbind().remove()

  set_title: (new_title) ->
    @title = new_title
    @set_view_data 'title', @title
    @render(true)
    @container.trigger('title_changed')

  set_message: (new_message) ->
    @message = new_message
    @set_view_data 'message', @message
    @render(true)

  #move the menu to a certain position
  set_position: (x, y) ->
    @container.css
      top: y
      left: x

  set_position_in_window: (pos='center') ->
    $w = $(window)
    @position_in_window = pos
    coords = [0, 0]
    center_x = $w.width() / 2 - @container.outerWidth() / 2
    center_y = $w.height() / 2 - @container.outerHeight() / 2
    left_x = 0
    right_x = $w.width() - @container.outerWidth()
    top_y = 0
    bottom_y = $w.height() - @container.outerHeight()

    switch @position_in_window
      when 'center'
        coords[0] = center_x
        coords[1] = center_y

      when 'n'
        coords[0] = center_x
        coords[1] = top_y

      when 'ne'
        coords[0] = right_x
        coords[1] = top_y

      when 'nw'
        coords[0] = left_x
        coords[1] = top_y

      when 'e'
        coords[0] = left_x
        coords[1] = center_y

      when 'w'
        coords[0] = right_x
        coords[1] = center_y

      when 's'
        coords[0] = center_x
        coords[1] = bottom_y

      when 'se'
        coords[0] = left_x
        coords[1] = bottom_y

      when 'sw'
        coords[0] = right_x
        coords[1] = bottom_y

    @set_position coords[0], coords[1]

  #set the position to the closest point deemed safe to 
  #the passed in x,y coordinates
  best_position_for: (x, y) ->
    x_padding = 40
    y_padding = -@container.height() / 2

    right_edge = x + @container.width() + x_padding
    #check if there is not enough room to the right
    if right_edge > $(window).width()
      #and then set it to the left
      x = x - @container.width() - x_padding
    #otherwise set it to the right
    else
      x += x_padding

    #don't go below 0
    if y + y_padding < 0
      y = y_padding
    #don't go over window height
    else if y + y_padding > $(window).height()
      y = $(window).height() - @container.height() - y_padding
    #safe
    else
      y += y_padding

    @set_position x, y

  trigger: (event_name='item_selected', value) ->
    @container.trigger event_name, value

  render_body: ->
    return unless @body_template

    @container.find('.body').empty()
    @container.find('.body').html @body_template @get_view_data()

  render: ->
    super

    @container.addClass @classes.join('') if !_.isEmpty @classes

    @render_body() if @body_template

World.Popup = Popup
