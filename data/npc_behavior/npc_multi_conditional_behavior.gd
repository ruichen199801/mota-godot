## Multi-branch conditional behavior. 
## Evaluates an ordered list of conditions, picks the first matching branch, or falls back.
## Use for NPC logic with 3+ branches.
class_name NpcMultiConditionalBehavior
extends NpcBehavior

@export var branches: Array[NpcConditionalData] = []
@export var fallback_behavior: NpcBehavior

var _chosen: NpcBehavior


func execute(npc_name: String, npc_frames: SpriteFrames, 
			 player_data: PlayerData) -> void:
	_chosen = null
	
	for branch in branches:
		if branch.condition and branch.condition.is_met(player_data):
			_chosen = branch.behavior
			break
		
	if _chosen == null:
		_chosen = fallback_behavior
			
	if _chosen:
		await _chosen.execute(npc_name, npc_frames, player_data)


## Delegates post actions to whichever branch was chosen.
## The multi-conditional behavior itself has no post actions.
func run_post_actions(grid_pos: Vector2i, player_data: PlayerData) -> void:
	if _chosen:
		await _chosen.run_post_actions(grid_pos, player_data)	
