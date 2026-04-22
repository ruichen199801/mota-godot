class_name NpcData
extends Resource

@export var npc_id: String
@export var npc_name: String
@export var frames: SpriteFrames
@export var behavior: NpcBehavior
## Only needed by NPCs with spawn_enemy action.
## If set, mind mirror shows this enemy's stats while the NPC is on the floor.
@export var preview_enemy: EnemyData
