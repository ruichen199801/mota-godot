class_name PlayerData
extends Resource

enum State {
	NORMAL,
	POISONED,
	WEAKENED,
}

const STATE_NAMES := {
	State.NORMAL: "正常",
	State.POISONED: "中毒",
	State.WEAKENED: "衰弱",
}

const POISON_DAMAGE := 5

var _weaken_debuffs := {
	"atk": 0,
	"def": 0,
	"agi": 0
}

@export var hit_frames: SpriteFrames
# Replace default hit effect with this after picking up any sword item
@export var sword_hit_frames: SpriteFrames

@export var state: State = State.NORMAL:
	set(v):
		if state == v:
			emit_changed()
			return
		var old_state := state
		state = v
		if old_state == State.WEAKENED:
			_restore_weaken()
		if v == State.WEAKENED:
			_apply_weaken()
		emit_changed()

@export var level: int = 1:
	set(v):
		level = v
		emit_changed()
		
@export var hp: int = 1000:
	set(v):
		hp = v
		emit_changed()
		
@export var atk: int = 10:
	set(v):
		atk = v
		emit_changed()
	
@export var def: int = 10:
	set(v):
		def = v
		emit_changed()

@export var crit: int = 5:
	set(v):
		crit = v
		emit_changed()

@export var agi: int = 2:
	set(v):
		agi = v
		emit_changed()

@export var atk_times: int = 1:
	set(v):
		atk_times = v
		emit_changed()

@export var xp: int = 0:
	set(v):
		xp = v
		emit_changed()

@export var yellow_keys: int = 1:
	set(v):
		yellow_keys = v
		emit_changed()

@export var blue_keys: int = 1:
	set(v):
		blue_keys = v
		emit_changed()

@export var red_keys: int = 1:
	set(v):
		red_keys = v
		emit_changed()

@export var gold: int = 0:
	set(v):
		gold = v
		emit_changed()

@export var atk_crit: int = 0:
	set(v):
		atk_crit = v
		emit_changed()
		
@export var def_crit: int = 0:
	set(v):
		def_crit = v
		emit_changed()
	
# --- Inventory ---

class InventorySlot:
	var data: ItemData
	var uses: int # -1 = permanent items
	
	func _init(_data: ItemData, _uses: int) -> void:
		data = _data
		uses = _uses
		
var inventory: Dictionary = {} # item_id -> InventorySlot


func add_to_inventory(item: ItemData, uses: int = -1) -> void:
	if item.item_id in inventory and uses > 0:
		inventory[item.item_id].uses += uses
	else:
		inventory[item.item_id] = InventorySlot.new(item, uses)	
	emit_changed()


func has_item(item_id: String) -> bool:
	return item_id in inventory


## Consumes one use of a consumable item. 
## e.g. anywhere door x5 -> x4
## Permanent items (-1 uses) always return true, never consumed.
func use_item(item_id: String) -> bool:
	if item_id not in inventory:
		return false
	var slot: InventorySlot = inventory[item_id]
	if slot.uses == -1:
		return true 
	if slot.uses <= 0:
		return false
	slot.uses -= 1
	if slot.uses == 0:
		inventory.erase(item_id)
	emit_changed()
	return true


## Removes (usually permanent) item entirely regardless of remaining uses.
## e.g. cross triggers after hp <= 0 in battle -> gone
func remove_item(item_id: String) -> bool:
	if item_id not in inventory:
		return false
	inventory.erase(item_id)
	emit_changed()
	return true

	
func get_item_data(item_id: String) -> ItemData:
	if item_id in inventory:
		return inventory[item_id].data
	return null


func get_item_uses(item_id: String) -> int:
	if item_id in inventory:
		return inventory[item_id].uses
	return 0

# --- Helpers ---

func get_state_name() -> String:
	return STATE_NAMES.get(state, "正常")
	
	
func is_poisoned() -> bool:
	return state == State.POISONED


func is_weakened() -> bool:
	return state == State.WEAKENED


func apply_poison() -> void:
	if state == State.POISONED:
		hp -= POISON_DAMAGE


func _apply_weaken() -> void:
	_weaken_debuffs.atk = atk / 2
	_weaken_debuffs.def = def / 2
	_weaken_debuffs.agi = agi / 2
	atk -= _weaken_debuffs.atk
	def -= _weaken_debuffs.def
	agi -= _weaken_debuffs.agi


func _restore_weaken() -> void:
	atk += _weaken_debuffs.atk
	def += _weaken_debuffs.def
	agi += _weaken_debuffs.agi
	_weaken_debuffs = {
		"atk": 0,
		"def": 0,
		"agi": 0
	}
