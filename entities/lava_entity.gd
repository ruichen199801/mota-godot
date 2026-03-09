class_name LavaEntity
extends TileEntity

const DAMAGE := 50


func is_blocking(pd: PlayerData) -> bool:
	if pd.has_item("ice_amulet"):
		return false
	return pd.hp <= DAMAGE
	
	
func on_enter(pd: PlayerData) -> void:
	if pd.has_item("ice_amulet"):
		remove_from_grid()
		return
	pd.hp -= DAMAGE
