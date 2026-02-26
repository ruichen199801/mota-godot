extends Node2D

@onready var walls: TileMapLayer = $Walls

func activate() -> void:
	GameData.clear_grid()
	# Register every painted wall tile into the grid dictionary
	for cell in walls.get_used_cells():
		GameData.set_cell(cell, GameData.CellType.WALL)
	print("Floor activated. Walls registered: ", GameData.grid.size())
