extends Node2D

@onready var floor_container: Node2D = $FloorContainer
@onready var player: Node2D = $Player
@onready var move_resolver: Node = $MoveResolver


func _ready() -> void:
	move_resolver.player = player
	
	player.init(Vector2i(5, 5))
	
	_load_all_floors()
	FloorManager.switch_to_floor(0)
	
	EventBus.floor_change_requested.connect(_on_floor_change)


func _load_all_floors() -> void:
	for i in range(0, FloorManager.TOTAL_FLOORS):
		var path := "res://floors/floor_%d.tscn" % i
		var scene: PackedScene = load(path)
		if scene == null:
			push_error("Missing floor scene: " + path)
			continue
			
		var floor_node: Node2D = scene.instantiate()
		floor_container.add_child(floor_node)
		var floor_grid: Dictionary = floor_node.setup()
		FloorManager.add_floor(i, floor_node, floor_grid)


func _on_floor_change(floor_id: int, spawn_pos: Vector2i) -> void:
	FloorManager.switch_to_floor(floor_id)
	player.place_at(spawn_pos)
