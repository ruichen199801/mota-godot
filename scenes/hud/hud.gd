extends Control

@onready var player_icon: TextureRect = %PlayerIcon
@onready var state_value: Label = %StateValue

@onready var level_value: Label = %LevelValue
@onready var hp_value: Label = %HPValue
@onready var atk_value: Label = %ATKValue
@onready var def_value: Label = %DEFValue
@onready var crit_value: Label = %CRITValue
@onready var agi_value: Label = %AGIValue
@onready var xp_value: Label = %XPValue

@onready var yellow_key_value: Label = %YellowKeyValue
@onready var blue_key_value: Label = %BlueKeyValue
@onready var red_key_value: Label = %RedKeyValue
@onready var gold_value: Label = %GoldValue

@onready var floor_label: Label = %FloorLabel

@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var items_button: Button = %ItemsButton
@onready var settings_button: Button = %SettingsButton

signal save_requested
signal load_requested
signal items_requested
signal settings_requested

var player_data: PlayerData


func _ready() -> void:
	save_button.pressed.connect(save_requested.emit)
	load_button.pressed.connect(load_requested.emit)
	items_button.pressed.connect(items_requested.emit)
	settings_button.pressed.connect(settings_requested.emit)
	
	EventBus.player_stats_changed.connect(refresh_stats)
	EventBus.player_keys_or_gold_changed.connect(refresh_keys_or_gold)
	EventBus.player_state_changed.connect(refresh_state)
	
	
func bind_player(data: PlayerData, icon: Texture2D) -> void:
	player_data = data
	if icon:
		player_icon.texture = icon
	refresh_all()
	

func refresh_all() -> void:
	if player_data == null:
		return
	refresh_stats()
	refresh_keys_or_gold()
	refresh_state()


func refresh_stats() -> void:
	level_value.text = str(player_data.level)
	hp_value.text = str(player_data.hp)
	atk_value.text = str(player_data.atk)
	def_value.text = str(player_data.def)
	crit_value.text = str(player_data.crit)
	agi_value.text = str(player_data.agi)
	xp_value.text = str(player_data.xp)


func refresh_keys_or_gold() -> void:
	yellow_key_value.text = str(player_data.yellow_keys)
	blue_key_value.text = str(player_data.blue_keys)
	red_key_value.text = str(player_data.red_keys)
	gold_value.text = str(player_data.gold)
	
	
func refresh_state() -> void:
	state_value.text = player_data.get_state_name()
	
	
func set_floor_display(floor_id: int) -> void:
	floor_label.text = "主塔   %dF" % floor_id
