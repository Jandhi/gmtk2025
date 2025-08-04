class_name Lever extends Sprite2D

enum State {
	SLOT,
	OFF,
	ON
}

var state : State = State.SLOT

@export var slot_collision : Node
@export var off_collision : Node
@export var on_collision : Node

@export var slot_texture : Texture2D
@export var off_texture : Texture2D
@export var on_texture : Texture2D

@export var clickable : Clickable
@export var hoverable : Hoverable
var is_interactable : bool = true
var parent_product : Product = null

func _ready():
	clickable.clicked.connect(on_click)
	if get_parent() is Product:
		parent_product = get_parent()
		parent_product.puzzle_count += 1

func on_click():
	if not is_interactable:
		return

	if state == State.OFF:
		set_state(State.ON)
		parent_product.puzzle_finished()
		AudioManager.play("snap")
	elif state == State.ON:
		set_state(State.OFF)
		parent_product.puzzle_unfinished()
		AudioManager.play("snap")

func set_state(new_state: State) -> void:
	state = new_state
	if new_state == State.SLOT:
		self.texture = slot_texture
		slot_collision.disabled = false
		off_collision.disabled = true
		on_collision.disabled = true
	elif new_state == State.OFF:
		self.texture = off_texture
		slot_collision.disabled = true
		off_collision.disabled = false
		on_collision.disabled = true
	elif new_state == State.ON:
		self.texture = on_texture
		slot_collision.disabled = true
		off_collision.disabled = true
		on_collision.disabled = false
