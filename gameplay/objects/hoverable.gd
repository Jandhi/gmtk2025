class_name Hoverable extends Node

@export var sprite : Sprite2D
@export var area : Area2D
var is_hovered: bool = false
var is_outline_locked: bool = false

func _ready():
	area.mouse_entered.connect(mouse_entered)
	area.mouse_exited.connect(mouse_exited)

func mouse_entered() -> void:
	if is_outline_locked:
		return

	set_outline_active(true)
	is_hovered = true

func mouse_exited() -> void:
	if is_outline_locked:
		return

	set_outline_active(false)
	is_hovered = false

func lock_outline() -> void:
	is_outline_locked = true

func unlock_outline() -> void:
	is_outline_locked = false

func set_outline_active(is_active: bool) -> void:
	sprite.material.set("shader_param/is_active", is_active)
