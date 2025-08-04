class_name Nail extends Sprite2D

@export var hoverable : Hoverable

var hammer_amount : int = 0
const HAMMER_THRESHOLD : int = 5
var parent_product : Product = null

var states : Array[Texture2D] = [
	preload("res://art/nail_out.png"),
	preload("res://art/nail_out_2.png"),
	preload("res://art/nail_out_3.png"),
	preload("res://art/nail_out_4.png"),
	preload("res://art/nail_out_5.png"),
	preload("res://art/nail_in.png")
]

func _ready():
	if get_parent() is Product:
		parent_product = get_parent()
		parent_product.puzzle_count += 1

func is_hammered() -> bool:
	return hammer_amount >= HAMMER_THRESHOLD

func hammer() -> void:
	hammer_amount = clamp(hammer_amount + 2, 0, HAMMER_THRESHOLD)
	self.texture = states[hammer_amount]

	if is_hammered():
		hoverable.unlock_outline()
		hoverable.mouse_exited()
		hoverable.lock_outline()
		parent_product.puzzle_finished()
