extends Node2D

@onready var floor_container: Node2D = $GameArea/FloorContainer
@onready var player: Node2D = $GameArea/Player
@onready var move_resolver: Node = $MoveResolver
@onready var hud: Control = $UILayer/HUD


func _ready() -> void:
	move_resolver.player = player
	player.init(Vector2i(5, 5))
	
	_load_all_floors()
	_switch_to_floor(0)
	
	EventBus.floor_change_requested.connect(_on_floor_change)
	
	hud.bind_player(player.data, player.get_icon())


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
	_switch_to_floor(floor_id)
	player.place_at(spawn_pos)
	

func _switch_to_floor(floor_id: int) -> void:
	FloorManager.switch_to_floor(floor_id)
	hud.set_floor_display(floor_id)
	EventBus.floor_switched.emit(floor_id)
