class_name LavaEntity
extends TileEntity

const DAMAGE := 50


func is_blocking(pd: PlayerData) -> bool:
	return pd.hp <= DAMAGE
	
	
func on_enter(pd: PlayerData) -> void:
	pd.hp -= DAMAGE
