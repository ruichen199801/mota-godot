class_name EdgePortalEntity
extends TileEntity

# Direction the player must move to trigger the portal
@export var trigger_direction: Vector2i
@export var dest_floor_id: String
@export var dest_pos: Vector2i

@onready var debug_sprite: Sprite2D = $DebugSprite


func _ready() -> void:
	if debug_sprite:
		debug_sprite.visible = false
		
		
func is_blocking(_player_data: PlayerData) -> bool:
	return false


func can_spawn_on() -> bool:
	return true
