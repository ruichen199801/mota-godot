class_name NpcRemoveAction
extends NpcPostAction


func apply(grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var entity := FloorManager.get_entity(grid_pos)
	
	# Calls queue_free() only later after on_block finishes to avoid crash
	if entity is NpcEntity:
		entity.visible = false
		for cell in entity.get_occupied_cells():
			FloorManager.remove_entity(cell)
			
	print("NPC removed at %s" % grid_pos)
