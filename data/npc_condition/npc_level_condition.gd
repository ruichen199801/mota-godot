class_name NpcLevelCondition
extends NpcCondition

@export var min_level: int = 1


func is_met(player_data: PlayerData) -> bool:
	return player_data.level >= min_level
