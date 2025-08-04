class_name Clock extends Sprite2D

signal time_hit

var tween : Tween = null
var time_is_hit : bool = false
@export var hand : Sprite2D

func start_clock():
	time_is_hit = false
	tween = get_tree().create_tween().set_parallel(false)
	tween.tween_property(hand, "rotation_degrees", 360, 80.0)
	await tween.finished

	if tween == null:
		return

	time_hit.emit()
	time_is_hit = true

func stop_clock():
	if tween != null:
		tween.stop()
		tween = null
	hand.rotation_degrees = 0.0
