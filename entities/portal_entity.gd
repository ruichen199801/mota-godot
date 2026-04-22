## A portal that transports the player to another floor when stepped on
## and moved in the trigger direction.
##
## Portals live in FloorData.portals (separate from the grid), so they
## co-exist with any grid entity (walls, doors, etc.) at the same cell.
class_name PortalEntity
extends TileEntity

## Direction the player must move to trigger the portal
@export var trigger_direction: Vector2i
@export var dest_floor_id: String
@export var dest_pos: Vector2i
## If set, player must have this item in inventory to use this portal
@export var required_item_id: String

@onready var debug_sprite: Sprite2D = $DebugSprite


func _ready() -> void:
	if debug_sprite:
		debug_sprite.visible = false
		
		
func is_blocking(_player_data: PlayerData) -> bool:
	return false


func can_spawn_on() -> bool:
	return true
