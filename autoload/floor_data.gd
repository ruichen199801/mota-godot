class_name FloorData
extends RefCounted

var node: Node2D
var grid: Dictionary = {} # Vector2i -> TileEntity

## Stores portals outside grid, because one cell maps to one entity only,
## but portals might need to co-exist with walls at the same cell,
## and portals should not be affected by grid entity removal/replace operations.
var portals: Dictionary = {} # Vector2i -> EdgePortalEntity


func _init(_node: Node2D, _grid: Dictionary, _portals: Dictionary = {}) -> void:
	node = _node
	grid = _grid
	portals = _portals
