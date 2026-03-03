extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var data: PlayerData
var icon: Texture2D: get = get_icon

var grid_pos: Vector2i
var facing := Vector2i.DOWN
var is_busy := false
var retry_timer := 0.0 

const MOVE_TIME := 0.12
const RETRY_DELAY := 0.15
const DEFAULT_TEMPLATE := preload("res://resources/player/default_player.tres")


func init(start_pos: Vector2i, template: PlayerData = null) -> void:
	if template == null:
		template = DEFAULT_TEMPLATE
	data = template.duplicate()
	place_at(start_pos)
	
	
func place_at(pos: Vector2i) -> void:
	grid_pos = pos
	position = FloorManager.grid_to_world(pos)
	is_busy = false
	_play_idle()
	
	
func _ready() -> void:
	EventBus.move_resolved.connect(_on_move_resolved)


func _process(_delta: float) -> void:
	if is_busy:
		return
		
	# Throttle re-request after player is blocked
	if retry_timer > 0:
		retry_timer -= _delta
		return
		
	var dir := _get_direction()
	if dir == Vector2i.ZERO:
		return
	
	facing = dir
	is_busy = true
	EventBus.move_requested.emit(dir)
	
	
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
	
	
func _on_move_resolved(target_pos: Vector2i, approved: bool) -> void:
	if approved:
		_do_move(target_pos)
	else:
		is_busy = false
		retry_timer = RETRY_DELAY
		_play_idle()
	
	
func _do_move(target: Vector2i) -> void:
	grid_pos = target
	_play_walk()
	
	var tween := create_tween()
	tween.tween_property(self, "position", 
		FloorManager.grid_to_world(target), MOVE_TIME)
	tween.finished.connect(func():
		is_busy = false
		if _get_direction() == Vector2i.ZERO:
			_play_idle()
	)


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
		

func get_icon() -> Texture2D:
	if anim and anim.sprite_frames:
		return anim.sprite_frames.get_frame_texture("idle_down", 0)
	return null
