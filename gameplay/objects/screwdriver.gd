class_name ScrewDriver extends Sprite2D

enum Mode {
	DROPPED,
	PICKED_UP,
	SCREWING
}

@export var screw_area : Area2D
@export var normal_texture : Dictionary[Screw.ScrewType, Texture2D]
@export var screwing_texture : Dictionary[Screw.ScrewType, Texture2D]
@export var draggable : Draggable
@export var hoverable : Hoverable
@export var clickable : Clickable
@export var normal_collider : Node
@export var screwing_collider : Node
@export var screw_type : Screw.ScrewType = Screw.ScrewType.PHILLIPS
var targeted_screw : Screw = null
var mode : Mode = Mode.DROPPED

func _ready():
	screw_area.area_entered.connect(on_screw_area_entered)
	screw_area.area_exited.connect(on_screw_area_exited)
	draggable.started_drag.connect(on_drag_started)
	draggable.dragged.connect(on_dragged)
	draggable.ended_drag.connect(on_drag_end)
	draggable.is_locked = true
	clickable.clicked.connect(on_clicked)
	self.texture = normal_texture[screw_type]

func enter_mode(new_mode: Mode) -> void:
	mode = new_mode
	if mode == Mode.PICKED_UP:
		draggable.process_mode = Node.PROCESS_MODE_DISABLED
		self.texture = normal_texture[screw_type]
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		AudioManager.play("pickup")
		set_boil_strength(1.0)
	elif mode == Mode.DROPPED:
		draggable.process_mode = Node.PROCESS_MODE_DISABLED
		self.texture = normal_texture[screw_type]
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		AudioManager.play("drop")
		set_boil_strength(0.0)
	elif mode == Mode.SCREWING:
		draggable.process_mode = Node.PROCESS_MODE_INHERIT
		AudioManager.play("screw_in", 0.3)
		enter_screwing_mode(targeted_screw)
		set_boil_strength(0.0)

func on_clicked():
	if mode == Mode.DROPPED:
		enter_mode(Mode.PICKED_UP)
	elif mode == Mode.PICKED_UP:
		if targeted_screw:
			enter_mode(Mode.SCREWING)
		else:
			enter_mode(Mode.DROPPED) 
	elif mode == Mode.SCREWING:
		exit_screwing_mode()

func _input(event):
	if mode == Mode.PICKED_UP and event is InputEventMouseMotion:
		self.position += event.relative

		if not hoverable.is_hovered:
			self.global_position = event.position

func on_screw_area_entered(area: Area2D) -> void:
	if mode != Mode.PICKED_UP:
		return

	if area.get_parent() is Screw and not area.get_parent().is_screwed and area.get_parent().screw_type == screw_type:
		targeted_screw = area.get_parent() as Screw
		var screw_hoverable = area.get_parent().find_child("Hoverable")
		screw_hoverable.mouse_entered()
		screw_hoverable.lock_outline()

func on_screw_area_exited(area: Area2D) -> void:
	if mode != Mode.PICKED_UP:
		return

	if area.get_parent() is Screw and not area.get_parent().is_screwed and area.get_parent().screw_type == screw_type:
		if mode != Mode.SCREWING:
			targeted_screw = null
		var screw_hoverable = area.get_parent().find_child("Hoverable")
		screw_hoverable.unlock_outline()
		screw_hoverable.mouse_exited()

func enter_screwing_mode(screw : Screw) -> void:
	mode = Mode.SCREWING
	draggable.is_dragging = false
	draggable.lock()
	self.texture = screwing_texture[screw.screw_type]
	self.global_position = screw.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	normal_collider.disabled = true
	screwing_collider.disabled = false

func exit_screwing_mode() -> void:
	self.rotation = 0
	mode = Mode.DROPPED
	targeted_screw = null
	hoverable.unlock_outline()
	hoverable.mouse_exited()
	draggable.unlock()
	draggable.is_dragging = false
	self.texture = normal_texture[screw_type]
	self.global_position = screw_area.global_position + Vector2(-30, 30)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	normal_collider.disabled = false
	screwing_collider.disabled = true
	enter_mode(Mode.DROPPED)

func on_drag_end() -> void:
	if mode == Mode.SCREWING:
		hoverable.mouse_exited()
		hoverable.unlock_outline()

		if targeted_screw != null and targeted_screw.screw_amount >= targeted_screw.SCREW_THRESHOLD:
			exit_screwing_mode()
		return

func set_mouse_pos(pos : Vector2) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var base_screen_size = Vector2(480, 270)
	var mouse_pos = Vector2(
			pos.x * viewport_size.x / base_screen_size.x,
			pos.y * viewport_size.y / base_screen_size.y
		)
	print("Setting mouse position to: ", mouse_pos)
	
	Input.warp_mouse(
		mouse_pos
	)

func on_dragged(relative: Vector2) -> void:
	if mode != Mode.SCREWING or targeted_screw == null or targeted_screw.screw_amount >= targeted_screw.SCREW_THRESHOLD:
		return

	var y_distance = clampf(relative.y, 0.0, INF);
	var rotation_amount = y_distance * 0.3
	targeted_screw.screw_amount += rotation_amount
	rotate(rotation_amount)

	AudioManager.play("squeak", 0.1, 0.2)

	if targeted_screw != null and targeted_screw.screw_amount >= targeted_screw.SCREW_THRESHOLD:
		self.rotation = 0

		if not targeted_screw.is_screwed:
			targeted_screw.set_screwed()
			

func on_drag_started() -> void:
	if mode == Mode.SCREWING:
		hoverable.lock_outline()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func set_boil_strength(amount : float) -> void:
	self.material.set("shader_param/distortion_strength", amount)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)