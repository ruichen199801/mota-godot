class_name ShopUI
extends Control

@onready var title_label: Label = %TitleLabel
@onready var avatar_sprite: AnimatedSprite2D = %AvatarSprite
@onready var description_label: RichTextLabel = %DescriptionLabel

@onready var option_rows: Array[HBoxContainer] = [%Option1, %Option2, %Option3, %LeaveOption]
@onready var arrows: Array[TextureRect] = [%Arrow1, %Arrow2, %Arrow3, %ArrowLeave]
@onready var option_labels: Array[RichTextLabel] = [%OptionLabel1, %OptionLabel2, %OptionLabel3]
@onready var cost_hints: Array[Label] = [%CostHint1, %CostHint2, %CostHint3]

var shop_entity: ShopEntity
var player_data: PlayerData
var selected_index := 0

const LEAVE_INDEX := 3
const OPTION_COUNT := 4


func _ready() -> void:
	visible = false
	for i in range(option_rows.size()):
		option_rows[i].mouse_entered.connect(_on_row_hover.bind(i))
		option_rows[i].gui_input.connect(_on_row_click.bind(i))


func open(entity: ShopEntity, pd: PlayerData) -> void:
	shop_entity = entity
	player_data = pd
	player_data.changed.connect(_refresh)

	title_label.text = entity.data.shop_name
	
	if entity.data.frames:
		avatar_sprite.sprite_frames = entity.data.frames
		avatar_sprite.play("avatar")

	selected_index = 0
	_refresh()
	_update_arrows()
	visible = true


func close() -> void:
	visible = false
	if player_data and player_data.changed.is_connected(_refresh):
		player_data.changed.disconnect(_refresh)
	shop_entity = null
	player_data = null


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("move_up"):
		selected_index = (selected_index - 1 + OPTION_COUNT) % OPTION_COUNT
		_update_arrows()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_down"):
		selected_index = (selected_index + 1) % OPTION_COUNT
		_update_arrows()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_confirm_selection()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	if shop_entity == null:
		return

	var sd: ShopData = shop_entity.data

	# Set description by shop type: gold shops have %d placeholder, xp shops are plain text
	if not sd.is_fixed_cost:
		description_label.set_content(sd.description % shop_entity.get_option_cost(sd.options[0]))
	else:
		description_label.set_content(sd.description)

	# Set option labels and cost hints
	for i in range(sd.options.size()):
		var opt: ShopOptionData = sd.options[i]
		option_labels[i].set_content(opt.label)

		if sd.is_fixed_cost:
			cost_hints[i].text = "（Exp %d）" % opt.fixed_cost
			cost_hints[i].visible = true
		else:
			cost_hints[i].visible = false


func _update_arrows() -> void:
	for i in range(arrows.size()):
		arrows[i].modulate.a = 1.0 if i == selected_index else 0.0
		
		
func _confirm_selection() -> void:
	if selected_index == LEAVE_INDEX:
		close()
		EventBus.shop_closed.emit()
		return

	var opt: ShopOptionData = shop_entity.data.options[selected_index]

	if shop_entity.can_afford(player_data, opt):
		var cost := shop_entity.get_option_cost(opt)
		shop_entity.purchase(player_data, opt)
		if shop_entity.data.currency == ShopData.CurrencyType.GOLD:
			print("Used %d gold, remaining: %d" % [cost, player_data.gold])
		else:
			print("Used %d exp, remaining: %d" % [cost, player_data.xp])
		_refresh()
	else:
		var cost := shop_entity.get_option_cost(opt)
		if shop_entity.data.currency == ShopData.CurrencyType.GOLD:
			print("Not enough gold: have %d, need %d" % [player_data.gold, cost])
		else:
			print("Not enough exp: have %d, need %d" % [player_data.xp, cost])


func _on_row_hover(index: int) -> void:
	selected_index = index
	_update_arrows()


func _on_row_click(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected_index = index
		_update_arrows()
		_confirm_selection()
