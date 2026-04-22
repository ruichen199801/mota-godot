## Two-branch conditional behavior. 
## Evaluates one condition, picks alt behavior if met, otherwise picks default behavior.
## Use for simple if/else NPC logic.
class_name NpcConditionalBehavior
extends NpcBehavior

@export var condition: NpcCondition
@export var default_behavior: NpcBehavior
@export var alt_behavior: NpcBehavior

var _chosen: NpcBehavior


func execute(npc_name: String, npc_frames: SpriteFrames, 
			 player_data: PlayerData) -> void:
	var chosen: NpcBehavior
	if condition and condition.is_met(player_data):
		chosen = alt_behavior
	else:
		chosen = default_behavior
		
	await chosen.execute(npc_name, npc_frames, player_data)
	_chosen = chosen


## Delegates post actions to whichever behavior was chosen.
## The conditional behavior itself has no post actions.
func run_post_actions(grid_pos: Vector2i, player_data: PlayerData) -> void:
	if _chosen:
		await _chosen.run_post_actions(grid_pos, player_data)
