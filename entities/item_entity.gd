class_name ItemEntity
extends TileEntity

@export var data: ItemData
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if data and data.icon:
		sprite.texture = data.icon


func is_blocking(_player_data: PlayerData) -> bool:
	return false


func on_enter(pd: PlayerData) -> void:
	match data.item_type:
		ItemData.ItemType.INSTANT:
			print("Applied instant item %s: %s" % [data.item_name, data.description])
			data.apply(pd)
		ItemData.ItemType.CONSUMABLE:
			print("Obtained consumable item %s: %s" % [data.item_name, data.description])
			pd.add_to_inventory(data, data.max_uses)
		ItemData.ItemType.PERMANENT:
			print("Obtained permanent item %s: %s" % [data.item_name, data.description])
			pd.add_to_inventory(data)
	remove_from_grid()
