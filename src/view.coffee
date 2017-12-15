class View extends SimpleModule
  opts:
    cls: ''

  inputTpl: '<input class="momentpicker-input" />'
  panelTpl: ''

  _init: ->
    @id = @opts.id
    @parent = @opts.parent
    @moment = @opts.moment

    @_render()
    @_bind()

  _render: ->
    @_renderInput()
    @_renderPanel()
    if @opts.inline
      @el.hide()
      @panel.show()
    else
      @_setPosition()

  _renderInput: ->
    @el = $(@inputTpl).addClass("#{@name}-input").attr
      'type': 'text'
      'placeholder': @parent.el.attr 'placeholder'
    @el.appendTo(@parent.el.parent())
    @el.val(@moment.format(@opts.format)) if @parent.el.val()

  _renderPanel: ->
    @panel = $(@panelTpl).html(@_getPanelTpl()).addClass(@opts.cls).attr('id', "#{@name}-#{@id}")
    if @opts.inline
      @panel.insertAfter(@parent.el)
    else
      @panel.insertAfter(@el)

  _getPanelTpl: ->
    @panelTpl

  _reRenderPanel: ->
    @panel.html(@_getPanelTpl())
    @_setPosition() if not @opts.inline

  _setPosition: ->
    position = @el.position()
    @panel.css
      'position': 'absolute'
      'left': position.left
      'top': position.top + @el.outerHeight(true)

  _bind: ->
    @_bindEl()
    @_bindPanel()

    $(document).on "mousedown.momentpicker-#{@id}", (e)=>
      return if @el.is(e.target) or !!@panel.has(e.target).length or @panel.is(e.target)
      @hide() unless @opts.inline
    $(window).on "resize.momentpicker-#{@id}", (e)=>
      @_setPosition()

  _bindEl: ->
    @el.on 'focus', =>
      @show()
    .on 'click', ->
      @select()
    .on 'keydown', (e)=>
      @verifyValue() if e.keyCode == 13
      @hide()
    .on 'change', =>
      @verifyValue()

  _bindPanel: ->
    @panel.on 'click', '.menu-item', (e)=>
      e.stopPropagation()
      @_menuItemHandler(e)

    .on 'click', '.panel-item', (e)=>
      e.stopPropagation()
      @_panelItemHandler(e)

  _menuItemHandler: ->
    false

  _panelItemHandler: ->
    false

  _setElValue: ->
    @el.val(@moment.format(@opts.format))
    @parent.trigger 'datechange',
      type: @name
      moment: @moment.clone()

  _clearElValue: ->
    @el.val('')
    @parent.trigger 'datechange',
      type: @name,
      moment: null,

  _setActive: ->
    @_reRenderPanel()

  verifyValue: ->
    new_moment = moment(@el.val(), @opts.format)
    @moment = new_moment if new_moment.isValid()

    if new_moment.parsingFlags().nullInput
      @_clearElValue()
    else
      @_setElValue()

  show: ->
    @_setActive()
    @panel.show()

  hide: ->
    @panel.hide()

  clear: ->
    @el.val ''
    @moment = moment()

  destroy: ->
    @panel.remove()
    @el.remove()
    $(document).off '.momentpicker-#{@id}'
    $(window).off '.momentpicker-#{@id}'

  setMoment: (m)->
    @moment = m
    @_setElValue()

  @addView: (view) ->
    unless @views
      @views = {}
    @views[view::name] = view
