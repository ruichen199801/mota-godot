extends Node

const CELL_SIZE := 32
const GRID_WIDTH := 11
const GRID_HEIGHT := 11
const TOTAL_FLOORS := 1

# Current floor's grid
var grid: Dictionary = {} # Vector2i -> TileEntity
var floors: Dictionary = {} # floor_id -> FloorData
var current_floor_id: int = -1 # Nothing loaded yet, cannot default to 0


# Entity methods
func get_entity(pos: Vector2i) -> TileEntity:
	return grid.get(pos, null)


func set_entity(pos: Vector2i, entity: TileEntity) -> void:
	grid[pos] = entity


func remove_entity(pos: Vector2i) -> void:
	grid.erase(pos)
	
	
func is_in_bounds(pos: Vector2i) -> bool:
	return (
		pos.x >= 0 and pos.x < GRID_WIDTH
		and pos.y >= 0 and pos.y < GRID_HEIGHT
	)
	
	
func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE)
	
	
# Floor methods
func add_floor(floor_id: int, node: Node2D, floor_grid: Dictionary) -> void:
	floors[floor_id] = FloorData.new(node, floor_grid)
	node.visible = false
	print("Added floor %d: %d cells" % [floor_id, floor_grid.size()])


func switch_to_floor(floor_id: int) -> void:
	if floor_id not in floors:
		push_error("Floor id %d does not exist" % floor_id)
		
	# Save current
	if current_floor_id in floors:
		floors[current_floor_id].grid = grid
		floors[current_floor_id].node.visible = false
		print("Stored floor %d: %d cells" % [current_floor_id, grid.size()])
		
	# Load new
	current_floor_id = floor_id
	grid = floors[floor_id].grid
	floors[floor_id].node.visible = true
	print("Switched to floor %d: %d cells" % [floor_id, grid.size()])
