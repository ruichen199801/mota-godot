class_name TileEntity
extends Node2D

var grid_pos: Vector2i

# Multi-cell entities
@export var cell_size: Vector2i = Vector2i(1, 1)
@export var interact_offset: Vector2i = Vector2i(0, 0)


func is_blocking(_player_data: PlayerData) -> bool:
	return true
	

func can_spawn_on() -> bool:
	return false


func on_block(_player_data: PlayerData) -> void:
	pass


func on_enter(_player_data: PlayerData) -> void:
	pass
	
	
func is_async() -> bool:
	return false


func remove_from_grid() -> void:
	for cell in get_occupied_cells():
		FloorManager.remove_entity(cell)
	queue_free()
	

func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(cell_size.x):
		for y in range(cell_size.y):
			cells.append(grid_pos + Vector2i(x, y))
	return cells
	

func get_interact_cell() -> Vector2i:
	return grid_pos + interact_offset
	
	
func is_interact_cell(cell: Vector2i) -> bool:
	return cell == get_interact_cell()
