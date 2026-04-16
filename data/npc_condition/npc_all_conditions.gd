class_name NpcAllConditions
extends NpcCondition

@export var conditions: Array[NpcCondition] = []


func is_met(player_data: PlayerData) -> bool:
	for c in conditions:
		if not c.is_met(player_data):
			return false
	return true
