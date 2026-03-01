class_name EnemyEntity
extends TileEntity

@export var data: EnemyData
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if data and data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")
