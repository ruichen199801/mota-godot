class_name AntidoteEffect
extends EffectData


func apply(pd: PlayerData) -> void:
	if pd.is_poisoned():
		pd.state = PlayerData.State.NORMAL
