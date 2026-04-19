class_name NpcMerchantData
extends Resource

enum CurrencyType { GOLD, XP }
enum TradeType { BUY, SELL }

@export var description: String
@export var currency: CurrencyType
@export var trade_type: TradeType
@export var one_time: bool # if set to true, the merchant must have npc_remove_action set as well
@export var options: Array[ShopOptionData] = [] # at most 3 options


func trade(player_data: PlayerData, option: ShopOptionData) -> bool:
	if not can_trade(player_data, option):
		return false
	
	match trade_type:
		TradeType.BUY:
			_buy(player_data, option)
		TradeType.SELL:
			_sell(player_data, option)
	return true


func can_trade(player_data: PlayerData, option: ShopOptionData) -> bool:
	match trade_type:
		TradeType.BUY:
			return _can_afford(player_data, option)
		TradeType.SELL:
			return _can_sell(player_data, option)
	return false


func _can_afford(player_data: PlayerData, option: ShopOptionData) -> bool:
	var cost := get_option_cost(option)
	match currency:
		CurrencyType.GOLD:
			return player_data.gold >= cost
		CurrencyType.XP:
			return player_data.xp >= cost
	return false
	
	
func _can_sell(player_data: PlayerData, option: ShopOptionData) -> bool:
	if option.yellow_keys < 0 and player_data.yellow_keys < abs(option.yellow_keys):
		return false
	if option.blue_keys < 0 and player_data.blue_keys < abs(option.blue_keys):
		return false
	if option.red_keys < 0 and player_data.red_keys < abs(option.red_keys):
		return false
	return true


func _buy(player_data: PlayerData, option: ShopOptionData) -> void:
	var cost := get_option_cost(option)
	match currency:
		CurrencyType.GOLD:
			player_data.gold -= cost
		CurrencyType.XP:
			player_data.xp -= cost
	option.apply_option(player_data)
	print("Merchant buy: cost %d %s" % [cost, "gold" if currency == CurrencyType.GOLD else "exp"])


func _sell(player_data: PlayerData, option: ShopOptionData) -> void:
	option.apply_option(player_data)
	var gain := get_option_cost(option)
	match currency:
		CurrencyType.GOLD:
			player_data.gold += gain
		CurrencyType.XP:
			player_data.xp += gain
	print("Merchant sell: gained %d %s" % [gain, "gold" if currency == CurrencyType.GOLD else "exp"])


func get_option_cost(option: ShopOptionData) -> int:
	return option.fixed_cost
