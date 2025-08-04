class_name DaySign extends Sprite2D

@export var text_label : RichTextLabel

func show_day(day : int) -> void:
	AudioManager.play("squeak")
	text_label.text = "[center][color=cc241d]" + str(day) + "[/color] days since last \"accident\""
	await get_tree().create_tween().tween_property(self, "position", Vector2(240, 135), 1.0).finished
	await get_tree().create_timer(1.0).timeout
	AudioManager.play("squeak")
	get_tree().create_tween().tween_property(self, "position", Vector2(240, 35), 1.0)
