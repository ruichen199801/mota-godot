class_name EnemyEntity
extends TileEntity

@export var data: EnemyData
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if data and data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")


func on_block(_player_data: PlayerData) -> void:
	# TODO: Implement battle system
	pass


func replace_with(new_data: EnemyData) -> void:
	data = new_data
	if data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")
