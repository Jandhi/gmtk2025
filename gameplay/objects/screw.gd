class_name Screw extends Sprite2D

@export var screw_type : ScrewType = ScrewType.PHILLIPS
@export var screw_out : Dictionary[ScrewType, Texture2D]
@export var screw_in : Dictionary[ScrewType, Texture2D]

@export var hoverable : Hoverable
var is_screwed: bool = false
var screw_amount : float
var parent_product : Product = null
const SCREW_THRESHOLD : float = 8.0

enum ScrewType {
	PHILLIPS,
	FLATHEAD,
	SQUARE
}

func _ready():
	self.texture = screw_out[screw_type]
	
	if get_parent() is Product:
		parent_product = get_parent()
		parent_product.puzzle_count += 1

func set_screwed() -> void:
	self.texture = screw_in[screw_type]
	hoverable.unlock_outline()
	hoverable.mouse_exited()
	hoverable.lock_outline()
	is_screwed = true
	parent_product.puzzle_finished()
	AudioManager.play("screw_done", 0.0, 2.0)
