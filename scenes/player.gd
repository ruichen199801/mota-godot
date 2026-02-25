extends Node2D

var is_moving := false
const MOVE_TIME := 0.1


func _ready() -> void:
	# Place player at starting grid position
	position = GameData.grid_to_world(GameData.player_grid_pos)
	print("Player ready at grid ", GameData.player_grid_pos, 
		" world ", position)
		
		
# https://forum.godotengine.org/t/difference-between-input-and-unhandled-input-functions/6995
func _unhandled_input(event: InputEvent) -> void:
	if is_moving:
		return
		
	var dir := Vector2i.ZERO
	if event.is_action_pressed("move_up"):
		dir = Vector2i.UP
	elif event.is_action_pressed("move_down"):
		dir = Vector2i.DOWN
	elif event.is_action_pressed("move_left"):
		dir = Vector2i.LEFT
	elif event.is_action_pressed("move_right"):
		dir = Vector2i.RIGHT
	
	if dir != Vector2i.ZERO:
		try_move(dir)
		
		
# TODO: Refactor using event bus
func try_move(dir: Vector2i) -> void:
	var target := GameData.player_grid_pos + dir
	
	# Boundary check
	if not GameData.is_in_bounds(target):
		print("Blocked: out of bounds ", target)
		return
		
	# Wall check
	var cell = GameData.get_cell(target)
	if cell != null and cell["type"] == "wall":
		print("Blocked: wall at ", target)
		return
		
	# Move
	do_move(target)
	
	
func do_move(target: Vector2i) -> void:
	GameData.player_grid_pos = target
	is_moving = true
	
	# Handle move animation
	var tween := create_tween()
	tween.tween_property(self, "position", 
		GameData.grid_to_world(target), MOVE_TIME)
	tween.finished.connect(
		func(): is_moving = false
	)
	
	print("Moved to ", target)
