extends Node

const CELL_SIZE := 32
const GRID_WIDTH := 11
const GRID_HEIGHT := 11

const START_FLOOR_ID := "main_0" # floor_id
const START_POS := Vector2i(5, 5)

const FLOOR_NAMES := { # floor_type -> floor_name
	"main": "主塔",
	"base": "地下", 
	"mota": "魔塔", 
}

const FLOOR_RANGES := { # floor_type -> floor_range
	"main": [0, 20],
	"base": [1, 25], 
	"mota": [1, 10], 
}

var floors: Dictionary = {} # floor_id -> FloorData
var grid: Dictionary = {} # Vector2i -> TileEntity
var current_floor_id: String = ""
var visited_floors: Array[String] = []

# --- Entity methods ---

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


func spawn_entity(scene: PackedScene, pos: Vector2i) -> TileEntity:
	var entity: TileEntity = scene.instantiate()
	entity.position = grid_to_world(pos)
	entity.grid_pos = pos
	
	var old_entity := get_entity(pos)
	if old_entity:
		old_entity.remove_from_grid()
	
	set_entity(pos, entity)
	floors[current_floor_id].node.get_node("Entities").add_child(entity)
	return entity
	
# --- Floor methods ---

func add_floor(floor_id: String, node: Node2D, floor_grid: Dictionary) -> void:
	floors[floor_id] = FloorData.new(node, floor_grid)
	node.visible = false
	print("Added floor %s: %d cells" % [floor_id, floor_grid.size()])


func switch_to_floor(floor_id: String) -> void:
	if floor_id not in floors:
		push_error("Floor id %s does not exist" % floor_id)
		return
		
	# Save current
	if current_floor_id in floors:
		floors[current_floor_id].grid = grid
		floors[current_floor_id].node.visible = false
		print("Stored floor %s: %d cells" % [current_floor_id, grid.size()])
		
	# Load new
	current_floor_id = floor_id
	grid = floors[floor_id].grid
	floors[floor_id].node.visible = true
	print("Switched to floor %s: %d cells" % [floor_id, grid.size()])
	
	if floor_id not in visited_floors:
		visited_floors.append(floor_id)
	
# --- Floor ID methods ---

func create_floor_id(floor_type: String, floor_num: int) -> String:
	return "%s_%d" % [floor_type, floor_num]
	
	
func parse_floor_id(floor_id: String) -> Array:
	var parts := floor_id.split("_")
	return [parts[0], parts[1].to_int()]


func get_floor_name(floor_id: String) -> String:
	var parsed := parse_floor_id(floor_id)
	var floor_type: String = parsed[0]
	var floor_num: int = parsed[1]
	
	if floor_type == "main" and floor_num == 0:
		return "%s   入口" % FLOOR_NAMES[floor_type]
	return "%s   %dF" % [FLOOR_NAMES[floor_type], floor_num]


func get_floor_scene_path(floor_id: String) -> String:
	var parsed := parse_floor_id(floor_id)
	return "res://floors/%s/floor_%s.tscn" % [parsed[0], parsed[1]]
