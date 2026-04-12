class_name StairEntity
extends TileEntity

enum StairDirection { UP, DOWN }

@export var stair_direction: StairDirection
@export var dest_floor_id: String
@export var dest_pos: Vector2i
# Only need to be set manually when more than one stair of the same kind exists on the same floor.
# If there is only one stair, it will be used as transport target by default.
@export var is_transport_target: bool = false
	

# Without this, player can't be placed on the stair
func can_spawn_on() -> bool:
	return true
	

func is_async() -> bool:
	return true
	
	
func on_block(_player_data: PlayerData) -> void:
	EventBus.floor_change_requested.emit(dest_floor_id, dest_pos)
	await EventBus.floor_change_completed
