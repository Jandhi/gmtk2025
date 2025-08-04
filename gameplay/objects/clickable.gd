class_name Clickable extends Node

signal clicked

@export var hoverable: Hoverable

func _input(event):
	if event is InputEventMouseButton and event.is_released() and hoverable.is_hovered:
		clicked.emit()