_ = require "underscore"
R = require "./R"
Model = require "../Model/Model"
Util = require "../Util/Util"


R.create "AttributeRow",
  propTypes:
    attribute: Model.Attribute

  contextTypes:
    project: Model.Project

  render: ->
    attribute = @props.attribute

    R.div {className: R.cx {
      AttributeRow: true
      isWrapped: @_isWrapped()
    }},
      R.div {className: "AttributeRowControl"},
        R.div {
          className: R.cx {
            AttributeControl: true
            Interactive: true
            # Controllable: @_isControllable()
            isControlled: @_isControlled()
            isImplicitlyControlled: @_isImplicityControlled()
          }
          onClick: @_toggleControl
        }
      R.div {className: "AttributeRowLabel"},
        R.AttributeLabel {attribute}
      R.div {className: "AttributeRowExpression"},
        R.Expression {attribute}

  _isWrapped: ->
    {attribute} = @props
    return attribute.exprString.indexOf("\n") != -1

  _isControlled: ->
    {attribute} = @props
    {project} = @context
    selectedElement = project.selectedParticularElement?.element
    return false unless selectedElement
    controlledAttributes = selectedElement.controlledAttributes()
    return _.contains(controlledAttributes, attribute)

  _isImplicityControlled: ->
    {attribute} = @props
    {project} = @context
    selectedElement = project.selectedParticularElement?.element
    return false unless selectedElement
    implicitlyControlledAttributes = selectedElement.implicitlyControlledAttributes()
    return _.contains(implicitlyControlledAttributes, attribute)

  # _isImplicityControlled: ->
  #   implicitlyControlledAttributes = State.Editor.getSelectedElement().getImplicitlyControlledAttributes()
  #   return _.contains(implicitlyControlledAttributes, @attribute)

  # _isControllable: ->
  #   controllableAttributes = State.Editor.getSelectedElement().getControllableAttributes()
  #   return _.contains(controllableAttributes, @attribute)

  _toggleControl: ->
    {attribute} = @props
    {project} = @context
    selectedElement = project.selectedParticularElement?.element
    return unless selectedElement
    if @_isControlled()
      selectedElement.removeControlledAttribute(attribute)
    else
      selectedElement.addControlledAttribute(attribute)


R.create "AttributeLabel",
  propTypes:
    attribute: Model.Attribute

  contextTypes:
    dragManager: R.DragManager
    hoverManager: R.HoverManager

  render: ->
    {attribute} = @props
    {hoverManager} = @context

    R.div {
      className: R.cx {
        AttributeLabel: true
        Interactive: true
        isHovered: hoverManager.hoveredAttribute == attribute
        # Variable: @node.parent().isVariantOf(Element)
      }
      onMouseDown: @_onMouseDown
      onMouseEnter: @_onMouseEnter
      onMouseLeave: @_onMouseLeave
    },
      R.EditableText {
        className: "EditableTextInline Interactive"
        value: attribute.label
        setValue: (newValue) ->
          attribute.label = newValue
      }

  _onMouseDown: (mouseDownEvent) ->
    return if Util.closest(mouseDownEvent.target, ".EditableTextInline")

    {attribute} = @props
    {dragManager, hoverManager} = @context
    mouseDownEvent.preventDefault()
    dragManager.start mouseDownEvent,
      type: "transcludeAttribute"
      attribute: attribute
      x: mouseDownEvent.clientX
      y: mouseDownEvent.clientY
      onMove: (mouseMoveEvent) ->
        dragManager.drag.x = mouseMoveEvent.clientX
        dragManager.drag.y = mouseMoveEvent.clientY
      onDrop: ->
        hoverManager.hoveredAttribute = null
      # cursor
      onCancel: =>
        @_transcludeIntoFocusedExpression()

  _transcludeIntoFocusedExpression: ->
    {attribute} = @props
    focusedCodeMirrorEl = document.querySelector(".CodeMirror-focused")
    return unless focusedCodeMirrorEl
    expressionCodeEl = Util.closest(focusedCodeMirrorEl, ".ExpressionCode")
    expressionCode = expressionCodeEl.component
    expressionCode.transcludeAttribute(attribute)

  _onMouseEnter: (e) ->
    {attribute} = @props
    {dragManager, hoverManager} = @context
    return if dragManager.drag?
    hoverManager.hoveredAttribute = attribute

  _onMouseLeave: (e) ->
    {dragManager, hoverManager} = @context
    return if dragManager.drag?
    hoverManager.hoveredAttribute = null


R.create "AttributeToken",
  propTypes:
    attribute: Model.Attribute
    # contextAttribute: {optional: Model.Attribute}

  contextTypes:
    dragManager: R.DragManager
    hoverManager: R.HoverManager

  render: ->
    {attribute} = @props
    {hoverManager} = @context

    R.span {
      className: R.cx {
        ReferenceToken: true
        isHovered: hoverManager.hoveredAttribute == attribute
      }
      onMouseEnter: @_onMouseEnter
      onMouseLeave: @_onMouseLeave
    },
      attribute.label

  # # TODO: This helper should be moved somewhere else (Node?)
  # _parentElement: (node) ->
  #   return null if !node?
  #   return node if node.isVariantOf(Model.Element)
  #   return @_parentElement(node.parent())

  # _label: ->
  #   if @contextAttribute
  #     contextElement = @_parentElement(@contextAttribute)
  #     element = @_parentElement(@attribute)
  #     isSameContext = element.isAncestorOf(contextElement)
  #     if !isSameContext
  #       return @attribute.parent().label + "’s " + @attribute.label
  #   return @attribute.label

  _onMouseEnter: (e) ->
    {attribute} = @props
    {dragManager, hoverManager} = @context
    return if dragManager.drag?
    hoverManager.hoveredAttribute = attribute

  _onMouseLeave: (e) ->
    {dragManager, hoverManager} = @context
    return if dragManager.drag?
    hoverManager.hoveredAttribute = null













