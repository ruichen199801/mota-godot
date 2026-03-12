extends Node2D

@onready var walls_tilemap: TileMapLayer = $Walls
@onready var entities_node: Node2D = $Entities

var wall_scene: PackedScene = preload("res://entities/wall_entity.tscn")

const REPLACEABLE_ALT_ID: int = 1


func setup() -> Dictionary:
	var floor_grid: Dictionary = {}
	
	# Load entity child scenes
	for child in entities_node.get_children():
		if child is TileEntity:
			var gp := Vector2i(
				Vector2(child.position) / Vector2(FloorManager.CELL_SIZE, FloorManager.CELL_SIZE)
			)
			child.position = Vector2(gp * FloorManager.CELL_SIZE)
			child.grid_pos = gp
			
			floor_grid[gp] = child	
			print("Loaded entity %s at %s" % [child.name, gp])
			for occ in child.get_occupied_cells():
				if occ != gp:
					floor_grid[occ] = child
					print("Loaded multi-cell entity %s at %s" % [child.name, occ])	
	
	# Load walls from tilemap
	print("Loaded %d walls" % walls_tilemap.get_used_cells().size())
	for cell in walls_tilemap.get_used_cells():
		if cell in floor_grid:
			continue
				
		var wall: WallEntity = wall_scene.instantiate()
		wall.position = Vector2(cell * FloorManager.CELL_SIZE)
		wall.grid_pos = cell
		wall.visible = false
		wall.source_tilemap = walls_tilemap
		
		var alt_id := walls_tilemap.get_cell_alternative_tile(cell)
		wall.replaceable = (alt_id == REPLACEABLE_ALT_ID)
		
		entities_node.add_child(wall)
		floor_grid[cell] = wall
	
	return floor_grid
