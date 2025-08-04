class_name Switch extends Sprite2D

@export var hoverable : Hoverable
@export var clickable : Clickable
@export var on_texture : Texture2D
@export var off_texture : Texture2D

var is_on: bool = false

func _ready():
	clickable.clicked.connect(on_click)
	self.texture = off_texture

func on_click():
	is_on = not is_on
	if is_on:
		self.texture = on_texture
		AudioManager.play("switch")
	else:
		self.texture = off_texture
		AudioManager.play("switch")
