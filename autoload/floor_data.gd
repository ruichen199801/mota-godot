class_name FloorData
extends RefCounted

var node: Node2D
var grid: Dictionary = {} # Vector2i -> TileEntity
var portals: Dictionary = {} # Vector2i -> PortalEntity


func _init(_node: Node2D, _grid: Dictionary, _portals: Dictionary = {}) -> void:
	node = _node
	grid = _grid
	portals = _portals
