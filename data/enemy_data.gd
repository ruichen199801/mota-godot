class_name EnemyData 
extends Resource

@export var enemy_id: String
@export var enemy_name: String
@export var frames: SpriteFrames
@export var hp: int
@export var atk: int
@export var def: int
@export var crit: int
@export var agi: int
@export var gold_drop: int
@export var xp_drop: int
@export var hit_frames: SpriteFrames

@export_group("Special Abilities")
@export var atk_times: int = 1
@export var poison_chance: int = 0
@export var weaken_chance: int = 0
# Ignore player defense entirely
@export var ignore_def: bool = false
# When player atk > enemy atk, enemy atk becomes player atk
@export var mirror_atk: bool = false
# When player atk > enemy def, enemy def becomes player atk - 1
@export var harden: bool = false
# Enemy atk = player def + this value, ignores base atk
@export var adaptive_atk: int = 0
# Spawns a new enemy at the same cell on death
@export var next_enemy: EnemyData
@export var ability_description: String = "没有"

var icon: Texture2D: get = _get_icon


func _get_icon() -> Texture2D:
	if frames == null:
		return null
	var first_anim = frames.get_animation_names()[0]
	return frames.get_frame_texture(first_anim, 0)
