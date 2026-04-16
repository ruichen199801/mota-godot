class_name NpcHasItemCondition
extends NpcCondition

@export var item_id: String


func is_met(player_data: PlayerData) -> bool:
	return player_data.has_item(item_id)
