class_name FloorTransportUI
extends Control

@onready var floor_prefix_label: Label = %FloorPrefixLabel
@onready var floor_number_label: Label = %FloorNumberLabel
@onready var up_arrow: TextureRect = %UpArrow
@onready var down_arrow: TextureRect = %DownArrow

## Sorted local copy of visited floors eligible for transport feature,
## E.g. ["base_2", "base_1", "main_0", "main_1", "main_2"]
var _visited_floors: Array[String] = []

## The currently selected floor in the UI list.
var _current_index := 0

## Hold-to-scroll: first press is instant, then repeats after initial delay
var _hold_timer := 0.0
var _hold_direction := 0 # 1 up, -1 down, 0 idle
const HOLD_INITIAL_DELAY := 0.2
const HOLD_REPEAT_RATE := 0.06


func _ready() -> void:
	visible = false
	up_arrow.gui_input.connect(_on_arrow_click.bind(1))
	down_arrow.gui_input.connect(_on_arrow_click.bind(-1))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("ui_cancel"):
		_hold_direction = 0
		close()
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("ui_accept"):
		_hold_direction = 0
		_confirm_floor_selection()
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_up"):
		_scroll_floor_selection(1)
		_hold_direction = 1
		_hold_timer = HOLD_INITIAL_DELAY
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_down"):
		_scroll_floor_selection(-1)
		_hold_direction = -1
		_hold_timer = HOLD_INITIAL_DELAY
		get_viewport().set_input_as_handled()
	
	elif event.is_action_released("move_up") or event.is_action_released("move_down"):
		_hold_direction = 0


func _process(delta: float) -> void:
	if not visible or _hold_direction == 0:
		return
	_hold_timer -= delta
	if _hold_timer <= 0:
		_hold_timer = HOLD_REPEAT_RATE
		_scroll_floor_selection(_hold_direction)
		
		
func open() -> void:
	_visited_floors.clear()
	_gather_visited_floors()

	if _visited_floors.is_empty():
		close()
		return

	_current_index = _visited_floors.find(FloorManager.current_floor_id)
	if _current_index < 0:
		_current_index = 0

	_refresh()
	visible = true


func close() -> void:
	visible = false
	EventBus.floor_transport_closed.emit()


func _gather_visited_floors() -> void:
	var entries: Array[String] = []
	for floor_id in FloorManager.visited_floors:
		if not FloorManager.is_transport_listed(floor_id):
			continue
		entries.append(floor_id)
	entries.sort_custom(func(a, b): return _get_floor_order(a) < _get_floor_order(b))
	_visited_floors = entries


## Sync the labels and arrow colors to match _current_index.
func _refresh() -> void:
	var floor_id: String = _visited_floors[_current_index]
	var floor_type := FloorManager.get_floor_type(floor_id)
	var floor_num := FloorManager.get_floor_num(floor_id)

	if floor_type == "base":
		floor_prefix_label.text = "B"
	else:
		floor_prefix_label.text = ""

	floor_number_label.text = str(floor_num)
	_update_arrows()


func _update_arrows() -> void:
	up_arrow.modulate = Color.WHITE if _current_index < _visited_floors.size() - 1 else Color.GRAY
	down_arrow.modulate = Color.WHITE if _current_index > 0 else Color.GRAY


func _confirm_floor_selection() -> void:
	var selected_id: String = _visited_floors[_current_index]
	var current_order := _get_floor_order(FloorManager.current_floor_id)
	var target_order := _get_floor_order(selected_id)

	var prefer_up: bool
	if current_order == target_order:
		# Same floor: positive floors -> down stair, non-positive -> up stair
		prefer_up = target_order <= 0
	else:
		# Different floor: going higher -> down stair, going lower -> up stair
		prefer_up = current_order > target_order

	var stair_pos := _find_stair(selected_id, prefer_up)
	if stair_pos == Vector2i(-1, -1):
		push_error("No stair found on floor %s" % selected_id)
		return

	visible = false
	EventBus.floor_transport_selected.emit(selected_id, stair_pos)


func _get_floor_order(floor_id: String) -> int:
	var floor_type := FloorManager.get_floor_type(floor_id)
	var floor_num := FloorManager.get_floor_num(floor_id)
	if floor_type == "base":
		return -floor_num
	return floor_num


## Find the best stair to land on for floor transport.
## Priority:
##   1. Stair with is_transport_target=true matching preferred direction
##   2. First stair matching preferred direction
## Returns (-1, -1) if no matching stair found.
func _find_stair(floor_id: String, prefer_up: bool) -> Vector2i:
	if floor_id not in FloorManager.floors:
		return Vector2i(-1, -1)

	var grid: Dictionary = FloorManager.floors[floor_id].grid 
	var preferred := StairEntity.StairDirection.UP if prefer_up else StairEntity.StairDirection.DOWN

	var first_match := Vector2i(-1, -1)
	
	for pos in grid:
		var entity = grid[pos]
		if entity is StairEntity and entity.stair_direction == preferred:
			if entity.is_transport_target:
				return entity.grid_pos
			if first_match == Vector2i(-1, -1):
				first_match = entity.grid_pos
	
	return first_match
	

func _on_arrow_click(event: InputEvent, direction: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_scroll_floor_selection(direction)


func _scroll_floor_selection(direction: int) -> void:
	var new_index := _current_index + direction
	if new_index >= 0 and new_index < _visited_floors.size():
		_current_index = new_index
		_refresh()
