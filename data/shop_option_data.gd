class_name ShopOptionData
extends Resource

@export var label: String

## For Shop, fixed_cost is only meaningful when is_fixed_cost is true.
## For NPC merchant, fixed_cost is always used.
##   1. For buy action, it equals what player pays.
##   2. For sell action, it equals what player receives.
@export var fixed_cost: int

@export var level: int
@export var hp: int
@export var atk: int
@export var def: int
# NPC merchant only
@export var yellow_keys: int
@export var blue_keys: int
@export var red_keys: int
@export var item: ItemData


## Applies the shop option to the player (stats, keys, gold, or item).
##   1. For buy action, the option values will be positive (cost deducted in advance).
##   2. For sell action, the option values will be negative (gain granted afterwards).
func apply_option(player_data: PlayerData) -> void:
	if level > 0:
		player_data.level += level
	if hp != 0:
		player_data.hp += hp
	if atk != 0:
		player_data.atk += atk
	if def != 0:
		player_data.def += def
	if yellow_keys != 0:
		player_data.yellow_keys += yellow_keys
	if blue_keys != 0:
		player_data.blue_keys += blue_keys
	if red_keys != 0:
		player_data.red_keys += red_keys
	if item:
		item.give_to(player_data)
