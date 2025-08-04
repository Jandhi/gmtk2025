class_name LeverPiece extends Sprite2D


enum Mode {
	DROPPED,
	PICKED_UP
}
var mode : Mode = Mode.DROPPED


@export var clickable : Clickable
@export var hoverable : Hoverable
@export var area : Area2D
var targeted_lever : Lever = null


func _ready():
	clickable.clicked.connect(on_clicked)
	hoverable.unlock_outline()
	area.area_entered.connect(on_lever_area_entered)
	area.area_exited.connect(on_lever_area_exited)

func enter_mode(new_mode: Mode) -> void:
	mode = new_mode
	if new_mode == Mode.PICKED_UP:
		hoverable.lock_outline()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_boil_strength(1.0)
		AudioManager.play("pickup")
	elif new_mode == Mode.DROPPED:
		hoverable.unlock_outline()
		set_boil_strength(0.0)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		AudioManager.play("drop")
	
func on_clicked():
	if mode == Mode.DROPPED:
		enter_mode(Mode.PICKED_UP)
	elif targeted_lever != null:
		targeted_lever.set_state(Lever.State.OFF)
		targeted_lever.is_interactable = false
		targeted_lever.hoverable.unlock_outline()
		targeted_lever.hoverable.mouse_entered()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		self.visible = false

		await get_tree().create_timer(0.1).timeout
		targeted_lever.is_interactable = true
		queue_free()
	else:
		enter_mode(Mode.DROPPED)


func _input(event):
	if mode == Mode.PICKED_UP and event is InputEventMouseMotion:
		self.position += event.relative

		if not hoverable.is_hovered:
			self.global_position = event.position

func on_lever_area_entered(area: Area2D) -> void:
	if area.get_parent() is Lever:
		targeted_lever = area.get_parent() as Lever
		var lever_hoverable = targeted_lever.find_child("Hoverable")
		lever_hoverable.mouse_entered()
		lever_hoverable.lock_outline()

func on_lever_area_exited(area: Area2D) -> void:
	if area.get_parent() is Lever:
		var lever_hoverable = targeted_lever.find_child("Hoverable")
		lever_hoverable.unlock_outline()
		lever_hoverable.mouse_exited()
		targeted_lever = null


func set_boil_strength(amount : float) -> void:
	self.material.set("shader_param/distortion_strength", amount)
