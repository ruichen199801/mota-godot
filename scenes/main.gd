extends Node2D

@onready var floor_container: Node2D = $FloorContainer
@onready var player: Node2D = $Player

var floor_scenes: Dictionary = {
	0: preload("res://floors/floor_0.tscn"),
}

var current_floor_node: Node2D = null


func _ready() -> void:
	load_floor(0)


func load_floor(floor_id: int) -> void:
	# Remove old floor if exists
	if current_floor_node:
		current_floor_node.queue_free()
		await current_floor_node.tree_exited
		
	# Instantiate new floor
	current_floor_node = floor_scenes[floor_id].instantiate()
	floor_container.add_child(current_floor_node)
	
	# Initialize tiles
	current_floor_node.activate()
	
	# Place player
	player.position = GameData.grid_to_world(GameData.player_grid_pos)
	
	print("Floor ", floor_id, " loaded")
