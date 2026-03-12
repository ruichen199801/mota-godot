class_name WallEntity
extends TileEntity

var source_tilemap: TileMapLayer
var replaceable: bool = false


func remove_from_grid() -> void:
	if source_tilemap:
		source_tilemap.erase_cell(grid_pos)
	super.remove_from_grid()
