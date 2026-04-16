class_name NpcRespawnAction
extends NpcPostAction

@export var target_floor: String
@export var target_pos: Vector2i
@export var new_data: NpcData


func apply(grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var entity := FloorManager.get_entity(grid_pos)
	if not entity is NpcEntity:
		return
	
	var npc_data: NpcData = new_data if new_data else entity.data
	var dest_floor := target_floor if target_floor else FloorManager.current_floor_id
	var dest_pos := target_pos if target_pos else grid_pos
	
	entity.remove_from_grid()
	
	var npc_scene: PackedScene = preload("res://entities/npc_entity.tscn")
	var new_npc: NpcEntity = FloorManager.spawn_entity_on_floor(
		npc_scene, dest_floor, dest_pos)
	new_npc.data = npc_data
	
	print("NPC respawned at %s %s" % [dest_floor, dest_pos])
