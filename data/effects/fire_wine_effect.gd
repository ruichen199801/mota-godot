class_name FireWineEffect
extends EffectData


func apply(pd: PlayerData) -> void:
	if pd.is_weakened():
		pd.state = PlayerData.State.NORMAL
	
