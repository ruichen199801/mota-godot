class_name NpcBehavior
extends Resource

@export var post_actions: Array[NpcPostAction] = []


func execute(_npc_name: String, _npc_frames: SpriteFrames, 
			 _player_data: PlayerData) -> void:
	pass


func run_post_actions(grid_pos: Vector2i, player_data: PlayerData) -> void:
	for action in post_actions:
		await action.apply(grid_pos, player_data)
