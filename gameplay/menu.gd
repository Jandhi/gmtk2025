class_name Menu extends Node

@export var clickable : Clickable
@export var game : Game

func _ready():
	AudioManager.play("ennui")
	clickable.clicked.connect(_on_click)

func _on_click():
	queue_free()
	game.start_game()
