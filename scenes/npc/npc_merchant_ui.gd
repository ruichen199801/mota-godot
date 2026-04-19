class_name NpcMerchantUI
extends Control

@onready var avatar_sprite: AnimatedSprite2D = %MerchantAvatarSprite
@onready var name_label: Label = %MerchantNameLabel
@onready var description_label: RichTextLabel = %MerchantDescLabel

@onready var option_rows: Array[HBoxContainer] = [%Option1, %Option2, %Option3, %LeaveOption]
@onready var arrows: Array[TextureRect] = [%Arrow1, %Arrow2, %Arrow3, %ArrowLeave]
@onready var option_labels: Array[RichTextLabel] = [%OptionLabel1, %OptionLabel2, %OptionLabel3]
@onready var cost_hints: Array[Label] = [%CostHint1, %CostHint2, %CostHint3]

var _merchant_data: NpcMerchantData
var _player_data: PlayerData
var _selected_index := 0
var _option_count := 0

const LEAVE_INDEX := 3


func _ready() -> void:
	visible = false
	for i in range(option_rows.size()):
		option_rows[i].mouse_entered.connect(_on_row_hover.bind(i))
		option_rows[i].gui_input.connect(_on_row_click.bind(i))


func open(npc_name: String, npc_frames: SpriteFrames,
		  merchant_data: NpcMerchantData, player_data: PlayerData) -> void:
	_merchant_data = merchant_data
	_player_data = player_data
	_player_data.changed.connect(_refresh)
	_option_count = merchant_data.options.size()

	if npc_frames:
		avatar_sprite.sprite_frames = npc_frames
		avatar_sprite.play("idle")

	name_label.text = npc_name
	description_label.set_content(merchant_data.description)

	for i in range(3):
		option_rows[i].visible = i < _option_count

	_selected_index = 0
	_refresh()
	_update_arrows()
	visible = true


func close() -> void:
	visible = false
	if _player_data and _player_data.changed.is_connected(_refresh):
		_player_data.changed.disconnect(_refresh)
	_merchant_data = null
	_player_data = null


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("move_up"):
		_selected_index = (_selected_index - 1 + _get_total_count()) % _get_total_count()
		_update_arrows()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down"):
		_selected_index = (_selected_index + 1) % _get_total_count()
		_update_arrows()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_selection()
		get_viewport().set_input_as_handled()
		
		
func _refresh() -> void:
	if _merchant_data == null:
		return

	var show_hints := _option_count > 1

	for i in range(_option_count):
		var opt: ShopOptionData = _merchant_data.options[i]
		option_labels[i].set_content(opt.label)

		if show_hints:
			var cost := _merchant_data.get_option_cost(opt)
			var currency_name := "$" \
				if _merchant_data.currency == NpcMerchantData.CurrencyType.GOLD \
				else "Exp"
			cost_hints[i].text = "(%s%d)" % [currency_name, cost]
			cost_hints[i].visible = true
		else:
			cost_hints[i].visible = false


func _update_arrows() -> void:
	var active_row := _get_row_index(_selected_index)
	for i in range(arrows.size()):
		arrows[i].modulate.a = 1.0 if i == active_row else 0.0


func _get_total_count() -> int:
	return _option_count + 1


func _get_row_index(sel_index: int) -> int:
	if sel_index < _option_count:
		return sel_index
	return LEAVE_INDEX


func _confirm_selection() -> void:
	if _selected_index == _option_count: # leave option
		close()
		EventBus.npc_merchant_closed.emit(false)
		return

	var opt: ShopOptionData = _merchant_data.options[_selected_index]

	if _merchant_data.can_trade(_player_data, opt):
		_merchant_data.trade(_player_data, opt)
		
		if _merchant_data.one_time:
			close()
			EventBus.npc_merchant_closed.emit(true)
		_refresh()
	else:
		print("Merchant: trade failed")


func _on_row_hover(index: int) -> void:
	if index == LEAVE_INDEX:
		_selected_index = _option_count
	elif index < _option_count:
		_selected_index = index
	_update_arrows()


func _on_row_click(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed \
	   and event.button_index == MOUSE_BUTTON_LEFT:
		_on_row_hover(index)
		_confirm_selection()
