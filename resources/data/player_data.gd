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

@export var state: State = State.NORMAL:
	set(v):
		state = v
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
		
# TODO: Add inventory


func get_state_name() -> String:
	return STATE_NAMES.get(state, "正常")
	
	
func is_poisoned() -> bool:
	return state == State.POISONED


func is_weakened() -> bool:
	return state == State.WEAKENED
