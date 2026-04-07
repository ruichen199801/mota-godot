class_name MindMirrorUI
extends Control

const ENEMIES_PER_PAGE := 3

@onready var page_container: VBoxContainer = %PageContainer
@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow

var _entries: Array[EnemyData] = []
var _player_data: PlayerData
var _current_page := 0
var _total_pages := 0

var _row_template: PackedScene = preload("res://scenes/mind_mirror/mind_mirror_row.tscn")


func _ready() -> void:
	visible = false
	left_arrow.gui_input.connect(_on_left_click)
	right_arrow.gui_input.connect(_on_right_click)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_prev_page()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_right"):
		_next_page()
		get_viewport().set_input_as_handled()
		
		
func open(player_data: PlayerData) -> void:
	_player_data = player_data
	_entries.clear()
	_gather_enemies()

	if _entries.is_empty():
		close()
		return

	_current_page = 0
	_total_pages = ceili(float(_entries.size()) / ENEMIES_PER_PAGE)
	_build_page()
	visible = true


func close() -> void:
	visible = false
	for child in page_container.get_children():
		child.queue_free()
	EventBus.mind_mirror_closed.emit()


func _gather_enemies() -> void:
	var seen_ids: Dictionary = {}
	for pos in FloorManager.grid:
		var entity = FloorManager.grid[pos]
		if entity is EnemyEntity and entity.data != null:
			var eid: String = entity.data.enemy_id
			if eid in seen_ids or eid == "fake_princess" or eid == "self":
				continue
			seen_ids[eid] = true
			_entries.append(entity.data)


func _build_page() -> void:
	for child in page_container.get_children():
		child.queue_free()

	var start := _current_page * ENEMIES_PER_PAGE
	var end := mini(start + ENEMIES_PER_PAGE, _entries.size())

	for i in range(start, end):
		var row: Control = _row_template.instantiate()
		page_container.add_child(row)
		_populate_row(row, _entries[i])

	_update_arrows()


func _populate_row(row: Control, ed: EnemyData) -> void:
	row.get_node("%NameLabel").text = ed.enemy_name
	row.get_node("%AbilityLabel").text = ed.ability_description

	var sprite: AnimatedSprite2D = row.get_node("%AvatarSprite")
	if ed.frames:
		sprite.sprite_frames = ed.frames
		sprite.play("idle")

	row.get_node("%HPValue").text = str(ed.hp)
	row.get_node("%ATKValue").text = str(ed.atk)
	row.get_node("%DEFValue").text = str(ed.def)
	row.get_node("%CRITValue").text = str(ed.crit)
	row.get_node("%AGIValue").text = str(ed.agi)
	row.get_node("%ATKTimesValue").text = str(ed.atk_times)
	row.get_node("%XPValue").text = str(ed.xp_drop)
	row.get_node("%GoldValue").text = str(ed.gold_drop)

	var est := _estimate_damage(ed)
	row.get_node("%EstDamageValue").text = "???" if est < 0 else str(est)


func _estimate_damage(ed: EnemyData) -> int:
	var player_hit := maxi(_player_data.atk - ed.def, 0)
	if player_hit <= 0:
		return -1
	var turns_to_kill := (ed.hp + player_hit - 1) / player_hit
	var enemy_hit := maxi(ed.atk - _player_data.def, 0)
	if enemy_hit <= 0:
		return 0
	return enemy_hit * (turns_to_kill - 1)


func _update_arrows() -> void:
	left_arrow.modulate = Color.WHITE if _current_page > 0 else Color.GRAY
	right_arrow.modulate = Color.WHITE if _current_page < _total_pages - 1 else Color.GRAY


func _prev_page() -> void:
	if _current_page > 0:
		_current_page -= 1
		_build_page()


func _next_page() -> void:
	if _current_page < _total_pages - 1:
		_current_page += 1
		_build_page()


func _on_left_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_prev_page()


func _on_right_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_next_page()
