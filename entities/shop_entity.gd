class_name ShopEntity
extends TileEntity

@export var data: ShopData
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var purchase_count: int = 0


func _ready() -> void:
	if data and data.frames:
		anim_sprite.sprite_frames = data.frames
		anim_sprite.play("default")
		

func is_async() -> bool:
	return true
	
	
func on_block(_player_data: PlayerData) -> void:
	EventBus.shop_opened.emit(self)
	print("Opening shop panel")
	await EventBus.shop_closed

# --- Purchase logic ---

func get_option_cost(option: ShopOptionData) -> int:
	if data.is_fixed_cost:
		return option.fixed_cost
	return data.base_cost + purchase_count * data.cost_increase
	

func can_afford(player_data: PlayerData, option: ShopOptionData) -> bool:
	var cost := get_option_cost(option)
	match data.currency:
		ShopData.CurrencyType.GOLD:
			return player_data.gold >= cost
		ShopData.CurrencyType.XP:
			return player_data.xp >= cost
	return false
	

func purchase(player_data: PlayerData, option: ShopOptionData) -> bool:
	if not can_afford(player_data, option):
		return false
	
	var cost := get_option_cost(option)
	
	match data.currency:
		ShopData.CurrencyType.GOLD:
			player_data.gold -= cost
		ShopData.CurrencyType.XP:
			player_data.xp -= cost
	
	if option.level > 0:
		player_data.level += option.level
	if option.hp != 0:
		player_data.hp += option.hp
	if option.atk != 0:
		player_data.atk += option.atk
	if option.def != 0:
		player_data.def += option.def
	
	purchase_count += 1
	return true
