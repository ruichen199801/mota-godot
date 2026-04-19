class_name EmblemUpgradeEffect
extends EffectData

@export var from_level: int = 0
@export var to_level: int = 1
@export var stat_effect: EffectData # only needed when emblem is identified (Lv0->Lv1)


func apply(player_data: PlayerData) -> void:
	if player_data.emblem_type == PlayerData.EmblemType.NONE:
		return
	if player_data.emblem_level != from_level:
		return
		
	player_data.emblem_level = to_level
	
	if stat_effect:
		stat_effect.apply(player_data)
