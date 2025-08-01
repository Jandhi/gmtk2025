class_name Screw extends Sprite2D

@export var not_screwed : Texture2D
@export var screwed : Texture2D
@export var hoverable : Hoverable
var is_screwed: bool = false
var screw_amount : float
const SCREW_THRESHOLD : float = 8.0

func set_screwed() -> void:
	self.texture = screwed
	hoverable.mouse_exited()
	hoverable.lock_outline()
	is_screwed = true
