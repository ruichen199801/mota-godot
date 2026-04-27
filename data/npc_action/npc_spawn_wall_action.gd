class_name NpcSpawnWallAction
extends NpcPostAction

@export var floor_id: String
@export var pos: Vector2i # which floor cell to spawn the wall on
@export var atlas_coords: Vector2i # which wall visual to use in the tilemap
@export var alt_id: int = 0


func apply(_grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var target_floor := floor_id if floor_id else FloorManager.current_floor_id
	FloorManager.spawn_wall(target_floor, pos, atlas_coords, alt_id)
