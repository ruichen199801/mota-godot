extends Node

const CELL_SIZE := 32
const GRID_WIDTH := 11
const GRID_HEIGHT := 11
const REPLACEABLE_ALT_ID: int = 1

const START_FLOOR_ID := "main_0" # floor_id
const START_POS := Vector2i(5, 10)

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

var transport_disabled: bool = false


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
	return spawn_entity_on_floor(scene, current_floor_id, pos)


func spawn_entity_on_floor(scene: PackedScene, floor_id: String,
						   pos: Vector2i) -> TileEntity:
	var entity: TileEntity = scene.instantiate()
	entity.position = grid_to_world(pos)
	entity.grid_pos = pos
	
	var old_entity: TileEntity = floors[floor_id].grid.get(pos, null)
	if old_entity:
		old_entity.remove_from_grid()
	
	floors[floor_id].grid[pos] = entity
	floors[floor_id].node.get_node("Entities").add_child(entity)
	return entity


func spawn_wall(floor_id: String, pos: Vector2i, atlas_coords: Vector2i, 
				alt_id: int = 0) -> void:
	if floor_id not in floors:
		return
		
	var floor_data: FloorData = floors[floor_id]
	var old_entity = floor_data.grid.get(pos, null)
	if old_entity:
		old_entity.remove_from_grid()
	
	var floor_node: Node2D = floor_data.node
	var walls_tilemap: TileMapLayer = floor_node.get_node("Walls")
	var entities_node: Node2D = floor_node.get_node("Entities")
	
	walls_tilemap.set_cell(pos, 0, atlas_coords, alt_id)
	
	var wall_scene: PackedScene = preload("res://entities/wall_entity.tscn")
	var wall: WallEntity = wall_scene.instantiate()
	wall.position = grid_to_world(pos)
	wall.grid_pos = pos
	wall.visible = false
	wall.source_tilemap = walls_tilemap
	wall.replaceable = (alt_id == REPLACEABLE_ALT_ID)
	
	entities_node.add_child(wall)
	floor_data.grid[pos] = wall
	print("Spawned wall at %s on %s" % [pos, floor_id])
	
	
# --- Floor methods ---

func add_floor(floor_id: String, node: Node2D, floor_grid: Dictionary, 
			   portal_map: Dictionary = {}) -> void:
	floors[floor_id] = FloorData.new(node, floor_grid, portal_map)
	node.visible = false
	print("Added floor %s: %d cells, %d portals" % [floor_id, floor_grid.size(), portal_map.size()])


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


func replace_floor(floor_id: String, new_scene_path: String) -> void:
	if floor_id not in floors:
		return
	
	var old_data: FloorData = floors[floor_id]
	var parent: Node = old_data.node.get_parent() # FloorContainer
	var was_visible: bool = old_data.node.visible
	
	old_data.node.visible = false
	old_data.node.queue_free()
	
	var scene: PackedScene = load(new_scene_path)
	var new_node: Node2D = scene.instantiate()
	parent.add_child(new_node)
	var result: Array = new_node.setup()
	
	floors[floor_id] = FloorData.new(new_node, result[0], result[1])
	new_node.visible = was_visible
	
	if current_floor_id == floor_id:
		grid = result[0]
	print("Replaced floor %s: %d cells, %d portals" % [floor_id, result[0].size(), result[1].size()])
	
	
## Returns the portal at given cell on current floor, or null if none exists.
func get_portal(pos: Vector2i) -> PortalEntity:
	if current_floor_id in floors:
		return floors[current_floor_id].portals.get(pos, null)
	return null
	
	
# --- Floor ID methods ---

func create_floor_id(floor_type: String, floor_num: int) -> String:
	return "%s_%d" % [floor_type, floor_num]
	

func get_floor_type(floor_id: String) -> String:
	return floor_id.split("_")[0]


func get_floor_num(floor_id: String) -> int:
	return floor_id.split("_")[1].to_int()
	
	
func get_floor_name(floor_id: String) -> String:
	var floor_type := get_floor_type(floor_id)
	var floor_num := get_floor_num(floor_id)
	
	if floor_type == "main" and floor_num == 0:
		return "%s   入口" % FLOOR_NAMES[floor_type]
	return "%s   %dF" % [FLOOR_NAMES[floor_type], floor_num]


func get_floor_scene_path(floor_id: String) -> String:
	return "res://floors/%s.tscn" % floor_id


## Whether this floor can appear in the transport floor list
func is_transport_destination(floor_id: String) -> bool:
	if get_floor_type(floor_id) == "mota":
		return false
	if floor_id in ["main_20", "base_25"]:
		return false
	return true
	

## Whether the player can use transport while on this floor
func is_transport_usable(floor_id: String) -> bool:
	if transport_disabled:
		return false
	if not is_transport_destination(floor_id):
		return false
	if floor_id in ["main_10"]:
		return false
	return true


func disable_transport() -> void:
	transport_disabled = true
