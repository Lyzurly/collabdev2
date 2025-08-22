extends Node

@export var sensitivity: float = .1
@export var max_offset: float = 1.

var viewport_center_x: float = 0.
var viewport_center_y: float = 0.
var offset_amount_x: float = 0.
var offset_amount_y: float = 0.

var using_mouse: bool = true
var mouse_above_player: bool = false
var mouse_inside_window: bool = true

var last_known_mouse_pos: Vector2 = Vector2.ZERO
var ignore_mouse: bool = false

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_update_viewport_center()
	get_viewport().size_changed.connect(_update_viewport_center)
	
func _notification(what: int):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_inside_window = true
		ignore_mouse = false
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		mouse_inside_window = false
		ignore_mouse = true

func _input(event: InputEvent) -> void:
	if GameStates.game_state == GameStates.game_states.GAMEPLAY:
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			using_mouse = true
			if mouse_inside_window:
				last_known_mouse_pos = event.position
		elif Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
			using_mouse = false
			Ground.ref.reset_slowed()
			if GameStates.game_state == GameStates.game_states.PAUSED:
				GameStates.update_game_state.emit(GameStates.game_states.GAMEPLAY)
				
	if SubMenu.ref.submenu == SubMenu.submenus.CUSTOMIZE:
		if event is InputEventMouseMotion or event is InputEventScreenTouch:
			process_mouse_pos_by_region(event.position)

func _update_viewport_center() -> void:
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	viewport_center_x = visible_rect.size.x * .5
	viewport_center_y = visible_rect.size.y * .5

func _process(_delta: float) -> void:
	var mouse_pos: Vector2
	if ignore_mouse:
		mouse_pos = last_known_mouse_pos
	else:
		mouse_pos = get_viewport().get_mouse_position()
	
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	var relative_x: float = mouse_pos.x - visible_rect.position.x
	var relative_y: float = mouse_pos.y - visible_rect.position.y
	
	var mouse_offset_x: float = (relative_x - viewport_center_x) / viewport_center_x
	offset_amount_x = lerp(offset_amount_x, mouse_offset_x * max_offset, sensitivity)
	offset_amount_x = clamp(offset_amount_x, -max_offset, max_offset)
	
	var mouse_offset_y: float = (relative_y - viewport_center_y) / viewport_center_x
	offset_amount_y = lerp(offset_amount_y, mouse_offset_y * max_offset, sensitivity)
	offset_amount_y = clamp(offset_amount_y, -max_offset, max_offset)
	
	if offset_amount_y < -.2:
		mouse_above_player = true
		Ground.ref.set_slowed_via_y(true)
	else:
		if mouse_above_player:
			mouse_above_player = false
			Ground.ref.set_slowed_via_y(false)

func process_mouse_pos_by_region(mouse_pos: Vector2) -> void:
	if is_point_in_designer_preview_region(mouse_pos):
		CharacterDesignerIcon.ref._on_mouse_entered()
	else:
		CharacterDesignerIcon.ref._on_mouse_exited()

func touch_is_in_region(_touch_pos: Vector2) -> bool:
	return true  #full region is ok for now

func is_point_in_designer_preview_region(point: Vector2) -> bool:
	var target_pos: Vector2 = CharacterDesignerIcon.ref.designer_container_submenu.global_position
	var target_size: Vector2 = CharacterDesignerIcon.ref.designer_container_submenu.size
	var target_rect: Rect2 = Rect2(target_pos, target_size)
	return target_rect.has_point(point)
