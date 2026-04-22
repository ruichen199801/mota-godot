class_name NpcEmblemCondition
extends NpcCondition

@export var emblem_type: PlayerData.EmblemType = PlayerData.EmblemType.NONE
@export var emblem_level: int = 0


func is_met(player_data: PlayerData) -> bool:
	if emblem_type != PlayerData.EmblemType.NONE and player_data.emblem_type != emblem_type:
		return false
	return player_data.emblem_level == emblem_level
