class_name FloorData
extends RefCounted

var node: Node2D
var grid: Dictionary = {} # Vector2i -> TileEntity


func _init(_node: Node2D, _grid: Dictionary) -> void:
	node = _node
	grid = _grid
