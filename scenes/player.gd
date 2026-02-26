extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_moving := false
var facing := Vector2i.DOWN
const MOVE_TIME := 0.15
		
		
func _process(_delta: float) -> void:
	if is_moving:
		return
		
	var dir := _get_direction()
	if dir != Vector2i.ZERO:
		_try_move(dir)
		
		
func _try_move(dir: Vector2i) -> void:
	facing = dir
	var target := GameData.player_grid_pos + dir
	
	# Boundary check
	if not GameData.is_in_bounds(target):
		_play_idle()
		return
		
	# Wall check
	var cell = GameData.get_cell(target)
	if cell != null and cell == GameData.CellType.WALL:
		_play_idle()
		return
		
	# Move
	_do_move(target)
	
	
func _do_move(target: Vector2i) -> void:
	GameData.player_grid_pos = target
	is_moving = true
	_play_walk()
	
	# Handle move animation
	var tween := create_tween()
	tween.tween_property(self, "position", 
		GameData.grid_to_world(target), MOVE_TIME)
	tween.finished.connect(_on_move_finished)
	
	
func _on_move_finished() -> void:
	is_moving = false
	if _get_direction() == Vector2i.ZERO:
		_play_idle()


func _get_direction() -> Vector2i:
	if Input.is_action_pressed("move_up"):
		return Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		return Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		return Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	else:
		return Vector2i.ZERO
	
	
func _play_walk() -> void:
	match facing:
		Vector2i.UP: anim.play("walk_up")
		Vector2i.DOWN: anim.play("walk_down")
		Vector2i.LEFT: anim.play("walk_left")
		Vector2i.RIGHT: anim.play("walk_right")


func _play_idle() -> void:
	match facing:
		Vector2i.UP: anim.play("idle_up")
		Vector2i.DOWN: anim.play("idle_down")
		Vector2i.LEFT: anim.play("idle_left")
		Vector2i.RIGHT: anim.play("idle_right")
