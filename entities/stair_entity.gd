class_name StairEntity
extends TileEntity

enum StairDirection { UP, DOWN }

@export var stair_direction: StairDirection
@export var dest_floor_id: String
@export var dest_pos: Vector2i
	

func can_spawn_on() -> bool:
	return true
	
	
func on_block(_player_data: PlayerData) -> void:
	EventBus.floor_change_requested.emit(dest_floor_id, dest_pos)
