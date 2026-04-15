class_name NpcSpawnEnemyAction
extends NpcPostAction

@export var enemy_data: EnemyData


func apply(grid_pos: Vector2i, _player_data: PlayerData) -> void:
	var entity := FloorManager.get_entity(grid_pos)
	if entity is NpcEntity:
		entity.remove_from_grid()
	
	var enemy_scene: PackedScene = preload("res://entities/enemy_entity.tscn")
	var enemy: EnemyEntity = FloorManager.spawn_entity(enemy_scene, grid_pos)
	enemy.data = enemy_data
	print("NPC transformed into %s at %s" % [enemy_data.enemy_name, grid_pos])
