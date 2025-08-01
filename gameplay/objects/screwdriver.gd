class_name ScrewDriver extends Sprite2D

enum Mode {
	NORMAL,
	SCREWING
}

@export var screw_area : Area2D
@export var normal_texture : Texture2D
@export var screwing_texture : Texture2D
@export var draggable : Draggable
@export var hoverable : Hoverable
@export var normal_collider : Node
@export var screwing_collider : Node
var targeted_screw : Screw = null
var mode : Mode = Mode.NORMAL

func _ready():
	screw_area.area_entered.connect(on_screw_area_entered)
	screw_area.area_exited.connect(on_screw_area_exited)
	draggable.started_drag.connect(on_drag_started)
	draggable.dragged.connect(on_dragged)
	draggable.ended_drag.connect(on_drag_end)

func on_screw_area_entered(area: Area2D) -> void:
	if area.get_parent() is Screw and not area.get_parent().is_screwed:
		targeted_screw = area.get_parent() as Screw
		var screw_hoverable = area.get_parent().find_child("Hoverable")
		screw_hoverable.mouse_entered()
		screw_hoverable.lock_outline()

func on_screw_area_exited(area: Area2D) -> void:
	if area.get_parent() is Screw and not area.get_parent().is_screwed:
		if mode == Mode.NORMAL:
			targeted_screw = null
		var screw_hoverable = area.get_parent().find_child("Hoverable")
		screw_hoverable.unlock_outline()
		screw_hoverable.mouse_exited()

func enter_screwing_mode(screw : Screw) -> void:
	mode = Mode.SCREWING
	draggable.is_dragging = false
	draggable.lock()
	self.texture = screwing_texture
	self.global_position = screw.global_position
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	normal_collider.process_mode = Node.PROCESS_MODE_DISABLED
	screwing_collider.process_mode = Node.PROCESS_MODE_INHERIT

func exit_screwing_mode() -> void:
	targeted_screw.set_screwed()
	mode = Mode.NORMAL
	targeted_screw = null
	hoverable.unlock_outline()
	hoverable.mouse_exited()
	draggable.unlock()
	draggable.is_dragging = false
	self.texture = normal_texture
	self.global_position = screw_area.global_position + Vector2(-30, 30)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	normal_collider.process_mode = Node.PROCESS_MODE_INHERIT
	screwing_collider.process_mode = Node.PROCESS_MODE_DISABLED

func on_drag_end() -> void:
	if mode == Mode.SCREWING:
		hoverable.mouse_exited()
		hoverable.unlock_outline()

		if targeted_screw != null and targeted_screw.screw_amount >= targeted_screw.SCREW_THRESHOLD:
			exit_screwing_mode()
		return
	
	if targeted_screw:
		enter_screwing_mode(targeted_screw)

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
	var rotation_amount = y_distance * 0.1
	targeted_screw.screw_amount += rotation_amount
	rotate(rotation_amount)

	if targeted_screw != null and targeted_screw.screw_amount >= targeted_screw.SCREW_THRESHOLD:
		self.rotation = 0

func on_drag_started() -> void:
	if mode == Mode.SCREWING:
		hoverable.lock_outline()
