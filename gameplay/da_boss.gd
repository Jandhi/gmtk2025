class_name DaBoss extends Sprite2D

@export var mouth : Sprite2D
@export var mouth_open_texture : Texture2D
@export var mouth_closed_texture : Texture2D
@export var speech_bubble : Sprite2D
@export var text_label : RichTextLabel

func boss_sequence(messages : Array[String]) -> void:
	set_not_talking()
	await show_boss()
	await get_tree().create_timer(0.5).timeout

	for message in messages:
		set_talking()
		await show_message(message)
		await get_tree().create_timer(1.0).timeout
		set_not_talking()
		text_label.text = ""
		await get_tree().create_timer(1.0).timeout

	await hide_boss()

func set_talking():
	mouth.texture = mouth_open_texture
	speech_bubble.visible = true

func set_not_talking():
	mouth.texture = mouth_closed_texture
	speech_bubble.visible = false

func show_boss() -> void:
	await get_tree().create_tween().tween_property(self, "position", Vector2(144, 108), 0.5).finished

func hide_boss() -> void:
	await get_tree().create_tween().tween_property(self, "position", Vector2(144, 400), 0.5).finished

func show_message(message : String) -> void:
	for word in message.split(" "):
		AudioManager.play("da_boss", 0.1)
		text_label.text += word + " "
		await get_tree().create_timer(0.15).timeout
