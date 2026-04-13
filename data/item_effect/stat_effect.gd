class_name StatEffect
extends EffectData

@export_group("Stat Effects")
@export var level: int
@export var hp: int
@export var atk: int
@export var def: int
@export var crit: int
@export var agi: int
@export var xp: int
@export var yellow_keys: int
@export var blue_keys: int
@export var red_keys: int
@export var gold: int
@export var atk_crit: int
@export var def_crit: int


func apply(pd: PlayerData) -> void:
	var stats = {
		"level": level,
		"hp": hp,
		"atk": atk,
		"def": def,
		"crit": crit,
		"agi": agi,
		"xp": xp,
		"yellow_keys": yellow_keys,
		"blue_keys": blue_keys,
		"red_keys": red_keys,
		"gold": gold,
		"atk_crit": atk_crit,
		"def_crit": def_crit
	}

	for key in stats:
		var value = stats[key]
		if value != 0:
			pd.set(key, pd.get(key) + value)
