class_name NpcAnyCondition
extends NpcCondition

@export var conditions: Array[NpcCondition] = []


func is_met(player_data: PlayerData) -> bool:
	for c in conditions:
		if c.is_met(player_data):
			return true
	return false
