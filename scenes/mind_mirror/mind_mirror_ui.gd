class_name MindMirrorUI
extends Control

const ENEMIES_PER_PAGE := 3

@onready var page_container: VBoxContainer = %PageContainer
@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow

var _entries: Array[EnemyData] = []
var _player_data: PlayerData
var _current_page := 0
var _total_pages := 1

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

	_current_page = 0
	_total_pages = maxi(ceili(float(_entries.size()) / ENEMIES_PER_PAGE), 1)
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
			if eid in seen_ids or entity.data.hidden_in_mind_mirror:
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


## Displays stats for all visible enemies on the current floor.
## For special enemy abilities or item effects:
##   - mirror_atk, magic_amulet will be shown in atk/def stats.
##   - harden, adaptive_atk will be hidden from the player.
func _populate_row(row: Control, ed: EnemyData) -> void:
	row.get_node("%NameLabel").text = ed.enemy_name
	row.get_node("%AbilityLabel").text = ed.ability_description

	var sprite: AnimatedSprite2D = row.get_node("%AvatarSprite")
	if ed.frames:
		sprite.sprite_frames = ed.frames
		sprite.play("idle")
	
	var effective_atk := ed.atk
	if ed.mirror_atk and _player_data.atk > ed.atk:
		effective_atk = _player_data.atk
		
	var effective_def := ed.def
	if _player_data.has_item("magic_amulet") and ed.vulnerable_to_magic_amulet:
		effective_def = maxi(ed.def - _player_data.def / 3, 0)

	row.get_node("%HPValue").text = str(ed.hp)
	row.get_node("%ATKValue").text = str(effective_atk)
	row.get_node("%DEFValue").text = str(effective_def)
	row.get_node("%CRITValue").text = str(ed.crit)
	row.get_node("%AGIValue").text = str(ed.agi)
	row.get_node("%ATKTimesValue").text = str(ed.atk_times)
	row.get_node("%XPValue").text = str(ed.xp_drop)
	row.get_node("%GoldValue").text = str(ed.gold_drop)

	var est := _estimate_damage(ed, effective_atk, effective_def)
	row.get_node("%EstDamageValue").text = str(est)


## Damage estimate based on vanilla (atk-def)*atk_times calculations.
## Shows theoretical total damage player would take to kill the enemy,
## regardless of current HP.
## 
## Supports:
##   - break adjustments (atk_crit, def_crit)
##   - certain enemy abilities (ignore_def, mirror_atk)
##   - certain item effects (magic_amulet)
##
## Ignores / Does not work on: 
##   - random events (crit, dodge, random emblem effects)
##   - certain enemy abilities (harden, adaptive_atk)
##   - special battle rules (silver_slime, gold_slime)
##
## Returns 9999999 if player can't damage enemy at all.
## Returns 0 if enemy can't hurt player.
func _estimate_damage(ed: EnemyData, effective_atk: int, effective_def: int) -> int:
	var player_hit := maxi(_player_data.atk - effective_def, 0)
	if player_hit == 0 and _player_data.atk + _player_data.atk_crit >= effective_def:
		player_hit = 1	
	
	# Player can't damage enemy at all
	if player_hit <= 0:
		return 9999999
	
	var player_damage_per_round := player_hit * _player_data.atk_times
	var turns_to_kill := (ed.hp + player_damage_per_round - 1) / player_damage_per_round
	
	var enemy_hit := maxi(effective_atk - _player_data.def, 0)
	if ed.ignore_def:
		enemy_hit = effective_atk
	if enemy_hit == 0 and effective_atk + _player_data.def_crit >= _player_data.def:
		enemy_hit = 1
		
	if enemy_hit <= 0:
		return 0
		
	# Player attacks first, so enemy gets (turns_to_skill-1) rounds of attacks
	return enemy_hit * ed.atk_times * (turns_to_kill - 1)


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
