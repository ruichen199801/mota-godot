class_name NpcEntity
extends TileEntity

@export var data: NpcData:
	set(v):
		data = v
		# Without this, the frames are only set once in _ready(), when data changes frames will be null 
		if is_inside_tree():
			_refresh_visuals()

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_refresh_visuals()


func _refresh_visuals() -> void:
	if data and data.frames:
		anim.sprite_frames = data.frames
		anim.play("idle")
		

func is_async() -> bool:
	return true
	
	
func on_block(player_data: PlayerData) -> void:
	if data and data.behavior:
		await data.behavior.execute(data.npc_name, data.frames, player_data)
		await data.behavior.run_post_actions(grid_pos, player_data)
		
		if FloorManager.get_entity(grid_pos) != self:
			queue_free()
