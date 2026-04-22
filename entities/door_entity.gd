class_name DoorEntity
extends TileEntity

enum DoorType { YELLOW, BLUE, RED, IRON, LOGIC }

@export var door_type: DoorType

## Logic gate behavior:
##   - If guard_positions is set, gate opens when all guarded cells have no enemies.
##   - If not set, gate opens when player has gem pickaxe (consumes one use).
@export var guard_positions: Array[Vector2i] = []

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const ANIM_NAMES := {
	DoorType.YELLOW: "yellow",
	DoorType.BLUE: "blue",
	DoorType.RED: "red",
	DoorType.IRON: "iron",
	DoorType.LOGIC: "logic",
}


func _ready() -> void:
	anim.animation = ANIM_NAMES[door_type]
	anim.frame = 0
	anim.stop()
	
	
func is_async() -> bool:
	return true
	
	
func on_block(pd: PlayerData) -> void:
	if not _can_open(pd):
		return	
	_consume_key(pd)
	anim.play()
	await anim.animation_finished
	remove_from_grid()
	
	
func _can_open(pd: PlayerData) -> bool:
	match door_type:
		DoorType.YELLOW: return pd.yellow_keys > 0
		DoorType.BLUE: return pd.blue_keys > 0
		DoorType.RED: return pd.red_keys > 0
		DoorType.IRON: return true
		DoorType.LOGIC: 
			if not guard_positions.is_empty():
				return _guards_cleared()
			return pd.get_item_uses("gem_pickaxe") > 0
	return false
	

func _consume_key(pd: PlayerData) -> void:
	match door_type:
		DoorType.YELLOW: pd.yellow_keys -= 1
		DoorType.BLUE: pd.blue_keys -= 1
		DoorType.RED: pd.red_keys -= 1
		DoorType.LOGIC: 
			if guard_positions.is_empty():
				pd.use_item("gem_pickaxe")


func _guards_cleared() -> bool:
	for pos in guard_positions:
		var entity = FloorManager.get_entity(pos)
		if entity is EnemyEntity:
			return false
	return true
