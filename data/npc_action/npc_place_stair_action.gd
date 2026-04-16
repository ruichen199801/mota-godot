class_name NpcPlaceStairAction
extends NpcPostAction

@export var floor_id: String
@export var pos: Vector2i
@export var stair_direction: StairEntity.StairDirection = StairEntity.StairDirection.DOWN
@export var stair_dest_floor: String
@export var stair_dest_pos: Vector2i
@export var is_transport_target: bool = false 

const STAIR_UP_SCENE: PackedScene = preload("res://entities/stair_up_entity.tscn")
const STAIR_DOWN_SCENE: PackedScene = preload("res://entities/stair_down_entity.tscn")


func apply(_grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var target_floor := floor_id if floor_id else FloorManager.current_floor_id
	var scene := STAIR_DOWN_SCENE if stair_direction == StairEntity.StairDirection.DOWN else STAIR_UP_SCENE
	var stair: StairEntity = FloorManager.spawn_entity_on_floor(
		scene, target_floor, pos)

	stair.stair_direction = stair_direction
	stair.dest_floor_id = stair_dest_floor
	stair.dest_pos = stair_dest_pos
	stair.is_transport_target = is_transport_target
	print("Stair placed at %s %s -> %s %s" % [
		target_floor, pos, stair_dest_floor, stair_dest_pos
	])
