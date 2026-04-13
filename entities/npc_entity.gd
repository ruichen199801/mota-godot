class_name NpcEntity
extends TileEntity

@export var data: NpcData

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if data and data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")
		

func is_async() -> bool:
	return true
	
	
func on_block(player_data: PlayerData) -> void:
	if data and data.behavior:
		await data.behavior.execute(data.npc_name, data.frames, player_data)
