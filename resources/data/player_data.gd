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

@export var state: State = State.NORMAL

@export var level: int = 1
@export var hp: int = 1000
@export var atk: int = 10
@export var def: int = 10
@export var crit: int = 5
@export var agi: int = 2
@export var xp: int = 0

@export var yellow_keys: int = 1
@export var blue_keys: int = 1
@export var red_keys: int = 1
@export var gold: int = 0

# TODO: Add inventory


func get_state_name() -> String:
	return STATE_NAMES.get(state, "正常")
	
	
func is_poisoned() -> bool:
	return state == State.POISONED


func is_weakened() -> bool:
	return state == State.WEAKENED
