class_name NpcMoveAndSwitchAction
extends NpcPostAction

@export var target_floor: String
@export var target_pos: Vector2i
@export var new_data: NpcData


func apply(grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var entity := FloorManager.get_entity(grid_pos)
	if not entity is NpcEntity:
		return
	
	var npc_data: NpcData = new_data if new_data else entity.data
	entity.remove_from_grid()
	
	var npc_scene: PackedScene = preload("res://entities/npc_entity.tscn")
	var new_npc: NpcEntity = FloorManager.spawn_entity_on_floor(
		npc_scene, target_floor, target_pos)
	new_npc.data = npc_data
	
	print("NPC respawned at %s %s" % [target_floor, target_pos])
