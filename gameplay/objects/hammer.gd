class_name Hammer extends Sprite2D

enum Mode {
	DROPPED,
	PICKED_UP
}

@export var clickable : Clickable
@export var hoverable : Hoverable
@export var hammer_area : Area2D
@export var normal_texture : Texture2D
@export var hammering_texture : Texture2D
var mode : Mode = Mode.DROPPED
var targeted_nail : Nail = null
var hammer_down : bool = false

func _ready():
	clickable.clicked.connect(on_clicked)
	hoverable.unlock_outline()
	hammer_area.area_entered.connect(on_nail_area_entered)
	hammer_area.area_exited.connect(on_nail_area_exited)

func on_nail_area_entered(area: Area2D) -> void:
	if mode != Mode.PICKED_UP:
		return

	if area.get_parent() is Nail and not area.get_parent().is_hammered():
		targeted_nail = area.get_parent() as Nail
		var nail_hoverable = area.get_parent().find_child("Hoverable")
		nail_hoverable.mouse_entered()
		nail_hoverable.lock_outline()

func on_nail_area_exited(area: Area2D) -> void:
	if mode != Mode.PICKED_UP:
		return

	if area.get_parent() is Nail:
		var nail_hoverable = area.get_parent().find_child("Hoverable")
		nail_hoverable.unlock_outline()
		nail_hoverable.mouse_exited()

func enter_mode(new_mode: Mode) -> void:
	mode = new_mode
	if mode == Mode.PICKED_UP:
		set_boil_strength(1.0)
		hoverable.lock_outline()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		AudioManager.play("pickup")
	elif mode == Mode.DROPPED:
		set_boil_strength(0.0)
		hoverable.unlock_outline()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		AudioManager.play("drop")

func set_boil_strength(amount : float) -> void:
	self.material.set("shader_param/distortion_strength", amount)

func _input(event):
	if mode == Mode.PICKED_UP and event is InputEventMouseMotion:
		self.position += event.relative

		if not hoverable.is_hovered:
			self.global_position = event.position

func on_clicked():
	if mode == Mode.DROPPED:
		enter_mode(Mode.PICKED_UP)
	elif mode == Mode.PICKED_UP and not hammer_down:
		if targeted_nail:
			hammer()
			return

		enter_mode(Mode.DROPPED)

func hammer():
	hammer_down = true
	targeted_nail.hammer()
	self.texture = hammering_texture

	if targeted_nail.is_hammered():
		targeted_nail = null
		AudioManager.play("hammer_done")
	else:
		AudioManager.play("hammer", 0.1)
	

	await get_tree().create_timer(0.2).timeout
	self.texture = normal_texture
	hammer_down = false

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)