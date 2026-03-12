class_name EnemyData 
extends Resource

@export var enemy_id: String
@export var enemy_name: String
@export var frames: SpriteFrames
@export var hp: int
@export var atk: int
@export var def: int
@export var gold_drop: int
@export var xp_drop: int

var icon: Texture2D: get = _get_icon


func _get_icon() -> Texture2D:
	if frames == null:
		return null
	var first_anim = frames.get_animation_names()[0]
	return frames.get_frame_texture(first_anim, 0)
