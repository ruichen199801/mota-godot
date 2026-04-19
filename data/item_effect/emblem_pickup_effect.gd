class_name EmblemPickupEffect
extends EffectData

@export var emblem_type: PlayerData.EmblemType


func apply(player_data: PlayerData) -> void:
	player_data.emblem_type = emblem_type
	player_data.emblem_level = 0
