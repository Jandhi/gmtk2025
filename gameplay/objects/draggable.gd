class_name Draggable extends Node

signal started_drag
signal ended_drag
signal dragged(relative: Vector2)

@export var sprite : Sprite2D
@export var hoverable : Hoverable
var is_dragging: bool = false
var is_locked : bool = false

func _input(event):
	if event is InputEventMouseButton:
		# is mouse down
		if event.pressed and hoverable.is_hovered:
			enter_drag()
			started_drag.emit()
		elif is_dragging:
			exit_drag()
			ended_drag.emit()

	if not is_dragging:
		return

	if event is InputEventMouseMotion:
		dragged.emit(event.relative)

		if not is_locked:
			# move the sprite with the mouse
			sprite.position += event.relative

func enter_drag() -> void:
	is_dragging = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func exit_drag() -> void:
	is_dragging = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func lock() -> void:
	is_locked = true
	if is_dragging:
		exit_drag()

func unlock() -> void:
	is_locked = false
