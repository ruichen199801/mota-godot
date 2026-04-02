class_name BattleUI
extends Control

signal battle_ui_dismissed
signal retreat_pressed

enum BattleUIState {
	# Battle UI is not visible. All input is ignored.
	CLOSED,
	
	# Combat loop is running. Player can press Q to retreat. Enter and click events are ignored.
	COMBAT_ACTIVE,
	
	# Player won. Result dropdown appears. Player must press Enter or click to dismiss the overlay.
	AWAITING_DISMISS,
	
	# Player HP reaches 0. Game over animation plays. All input is ignored. 
	GAME_OVER,
}

@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_sprite: AnimatedSprite2D = %EnemySprite
@onready var enemy_hit_effect: AnimatedSprite2D = %EnemyHitEffect
@onready var enemy_miss_label: Label = %EnemyMissLabel
@onready var enemy_hp_value: Label = %EnemyHPValue
@onready var enemy_atk_value: Label = %EnemyATKValue
@onready var enemy_def_value: Label = %EnemyDEFValue
@onready var enemy_crit_value: Label = %EnemyCRITValue
@onready var enemy_agi_value: Label = %EnemyAGIValue

@onready var player_icon_rect: TextureRect = %PlayerIcon
@onready var player_hit_effect: AnimatedSprite2D = %PlayerHitEffect
@onready var player_miss_label: Label = %PlayerMissLabel
@onready var player_hp_value: Label = %PlayerHPValue
@onready var player_atk_value: Label = %PlayerATKValue
@onready var player_def_value: Label = %PlayerDEFValue
@onready var player_crit_value: Label = %PlayerCRITValue
@onready var player_agi_value: Label = %PlayerAGIValue

@onready var result_border: Panel = %ResultBorder
@onready var result_content: Control = %ResultContent
@onready var result_xp_label: RichTextLabel = %ResultXPLabel
@onready var result_gold_label: RichTextLabel = %ResultGoldLabel

@onready var retreat_hint_label: RichTextLabel = %RetreatHintLabel
@onready var dismiss_hint_label: Label = %DismissHintLabel
@onready var game_over_label: Label = %GameOverLabel
@onready var battle_border: PanelContainer = %BattleBorder

const MISS_FLOAT_DISTANCE := 20.0
const MISS_FLOAT_DURATION := 0.4
const RESULT_EXTEND_DURATION := 0.3
const RESULT_HEIGHT := 32.0
const GAME_OVER_FLOAT_DURATION := 2.0
const GAME_OVER_HOLD_DURATION := 2.0
const GAME_OVER_FADE_DURATION := 1.0
const NUM_FONT := "res://assets/fonts/system_font.tres"

var _state := BattleUIState.CLOSED


func _ready() -> void:
	self.visible = false
	_reset_battle_effects()
	
	
func _unhandled_input(event: InputEvent) -> void:
	match _state:
		BattleUIState.COMBAT_ACTIVE:
			if event.is_action_pressed("retreat"):
				retreat_pressed.emit()
				get_viewport().set_input_as_handled()
		BattleUIState.AWAITING_DISMISS:
			if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
				battle_ui_dismissed.emit()
				get_viewport().set_input_as_handled()
	

func show_battle(player_data: PlayerData, enemy_data: EnemyData, player_icon: Texture2D, 
				enemy_atk: int, enemy_def: int) -> void:
	_reset_battle_effects()

	enemy_name_label.text = enemy_data.enemy_name
	if enemy_data.frames:
		enemy_sprite.sprite_frames = enemy_data.frames
		enemy_sprite.play("idle")
	enemy_hp_value.text = str(enemy_data.hp)
	enemy_atk_value.text = str(enemy_atk)
	enemy_def_value.text = str(enemy_def)
	enemy_crit_value.text = str(enemy_data.crit)
	enemy_agi_value.text = str(enemy_data.agi)

	if player_icon:
		player_icon_rect.texture = player_icon
	player_hp_value.text = str(player_data.hp)
	player_atk_value.text = str(player_data.atk)
	player_def_value.text = str(player_data.def)
	player_crit_value.text = str(player_data.crit)
	player_agi_value.text = str(player_data.agi)

	_set_state(BattleUIState.COMBAT_ACTIVE)
	self.visible = true
	
	
func hide_battle() -> void:
	self.visible = false
	_set_state(BattleUIState.CLOSED)
	

func update_hp(player_hp: int, enemy_hp: int) -> void:
	player_hp_value.text = str(maxi(player_hp, 0))
	enemy_hp_value.text = str(maxi(enemy_hp, 0))
	
	
func play_hit(on_enemy: bool, frames: SpriteFrames, anim_name: String) -> void:
	if frames == null or anim_name == "":
		return
	var effect: AnimatedSprite2D = enemy_hit_effect if on_enemy else player_hit_effect
	effect.sprite_frames = frames
	effect.visible = true
	effect.play(anim_name)
	await effect.animation_finished
	effect.visible = false


func play_miss(on_enemy: bool) -> void:
	var miss_label: Label = enemy_miss_label if on_enemy else player_miss_label
	miss_label.modulate.a = 1.0
	miss_label.visible = true
	miss_label.position.y = 0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(miss_label, "position:y", -MISS_FLOAT_DISTANCE, MISS_FLOAT_DURATION)
	tween.tween_property(miss_label, "modulate:a", 0.0, MISS_FLOAT_DURATION)
	await tween.finished
	miss_label.visible = false


func play_game_over() -> void:
	_set_state(BattleUIState.GAME_OVER)
	
	game_over_label.modulate.a = 1.0
	game_over_label.visible = true
	
	var border_pos := battle_border.position
	var border_size := battle_border.size
	var label_height := game_over_label.size.y

	# Start below center
	var center_y := border_pos.y + (border_size.y - label_height) / 2.0
	var start_y := border_pos.y + border_size.y
	
	game_over_label.position.x = border_pos.x + (border_size.x - game_over_label.size.x) / 2.0
	game_over_label.position.y = start_y

	# Float up to center
	var float_tween := create_tween()
	float_tween.tween_property(game_over_label, "position:y", center_y, GAME_OVER_FLOAT_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await float_tween.finished

	# Hold
	await get_tree().create_timer(GAME_OVER_HOLD_DURATION).timeout

	# Fade out
	var fade_tween := create_tween()
	fade_tween.tween_property(game_over_label, "modulate:a", 0.0, GAME_OVER_FADE_DURATION)
	await fade_tween.finished

	game_over_label.visible = false
	
	
func show_result(xp: int, gold: int) -> void:
	result_xp_label.text = _styled_result("经验值：", xp)
	result_gold_label.text = _styled_result("金币：", gold)

	result_content.visible = false
	result_border.size.y = true
	result_border.visible = true

	var tween := create_tween()
	tween.tween_property(result_border, "size:y", RESULT_HEIGHT, RESULT_EXTEND_DURATION)
	await tween.finished
	
	result_content.visible = true
	
	
func wait_for_dismiss() -> void:
	_set_state(BattleUIState.AWAITING_DISMISS)
	await battle_ui_dismissed
	
	
func _set_state(new_state: BattleUIState) -> void:
	_state = new_state
	retreat_hint_label.visible = (_state == BattleUIState.COMBAT_ACTIVE)
	dismiss_hint_label.visible = (_state == BattleUIState.AWAITING_DISMISS)
			
			
func _reset_battle_effects() -> void:
	enemy_hit_effect.visible = false
	enemy_miss_label.visible = false
	player_hit_effect.visible = false
	player_miss_label.visible = false
	result_border.visible = false
	result_border.size.y = 0
	result_content.visible = false
	retreat_hint_label.visible = false
	dismiss_hint_label.visible = false
	game_over_label.visible = false


func _styled_result(label_text: String, value: int) -> String:
	return "%s[font=%s]%d[/font]" % [label_text, NUM_FONT, value]
