extends Node

@export var sensitivity: float = .1
@export var max_offset: float = 1.

var mouse_offset: Vector2
var mouse_relative: Vector2

var viewport_center_x: float = 0.
var viewport_center_y: float = 0.
var offset_amount_x: float = 0.
var offset_amount_y: float = 0.

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
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if mouse_inside_window:
			last_known_mouse_pos = event.position

func _update_viewport_center() -> void:
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	viewport_center_x = visible_rect.size.x * .5
	viewport_center_y = visible_rect.size.y * .5

func _process(_delta: float) -> void:
	var mouse_pos: Vector2
	mouse_pos = last_known_mouse_pos
	mouse_pos = get_viewport().get_mouse_position()
	
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	var relative_x: float = mouse_pos.x - visible_rect.position.x
	var relative_y: float = mouse_pos.y - visible_rect.position.y
	
	mouse_relative = Vector2(relative_x,relative_y)
	
	var mouse_offset_x: float = (relative_x - viewport_center_x) / viewport_center_x
	offset_amount_x = lerp(offset_amount_x, mouse_offset_x * max_offset, sensitivity)
	offset_amount_x = clamp(offset_amount_x, -max_offset, max_offset)
	
	var mouse_offset_y: float = (relative_y - viewport_center_y) / viewport_center_x
	offset_amount_y = lerp(offset_amount_y, mouse_offset_y * max_offset, sensitivity)
	offset_amount_y = clamp(offset_amount_y, -max_offset, max_offset)
	
	mouse_offset = Vector2(mouse_offset_x,mouse_offset_y)
	
	#print("Relative: ",mouse_relative," Offset: ",mouse_offset)

func touch_is_in_region(_touch_pos: Vector2) -> bool:
	return true  #full region is ok for now
