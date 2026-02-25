extends Node

const CELL_SIZE := 32
const GRID_WIDTH := 11
const GRID_HEIGHT := 11

var player_grid_pos: Vector2i = Vector2i(5, 5)

# Key: cell coordinate, e.g. Vector2i(1, 1)
# Value: a dict with info about what's in the cell, or null, e.g. { "type": "enemy", "node": <Enemy#123> }
var grid: Dictionary = {}


func clear_grid() -> void:
	grid.clear()
	

# Returns dict or null
func get_cell(pos: Vector2i):
	return grid.get(pos, null)
	
	
func set_cell(pos: Vector2i, data) -> void:
	if data == null:
		grid.erase(pos)
	else:
		grid[pos] = data
		

# (0, 0) -> +X (right)
#   |
#  +Y (down)
func is_in_bounds(pos: Vector2i) -> bool:
	return (
		pos.x >= 0 and pos.x < GRID_WIDTH
		and pos.y >= 0 and pos.y < GRID_HEIGHT
	)
	
	
# Converts grid coordinates to pixel coordinates needed by Godot to render
func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE)
