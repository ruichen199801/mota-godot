class_name ShopData
extends Resource

enum CurrencyType { GOLD, XP }

@export var shop_id: String
@export var shop_name: String
@export var currency: CurrencyType
@export var frames: SpriteFrames

@export_group("Cost")
@export var is_fixed_cost: bool
@export var base_cost: int # only used when is_fixed_cost is false
@export var cost_increase: int # only used when is_fixed_cost is false

@export_group("Options")
@export var options: Array[ShopOptionData]
