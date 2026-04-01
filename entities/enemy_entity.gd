class_name EnemyEntity
extends TileEntity

@export var data: EnemyData:
	set(v):
		data = v
		if is_inside_tree():
			_refresh_visuals()
		
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_refresh_visuals()


func is_async() -> bool:
	return true


func on_block(player_data: PlayerData) -> void:
	EventBus.battle_requested.emit(self, player_data)
	await EventBus.battle_finished


func replace_with(new_data: EnemyData) -> void:
	data = new_data
	if data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")


func _refresh_visuals() -> void:
	if data and data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")
