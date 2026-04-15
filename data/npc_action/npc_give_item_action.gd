class_name NpcGiveItemAction
extends NpcPostAction

@export var item: ItemData


func apply(_grid_pos: Vector2i, player_data: PlayerData) -> void:
	if not item:
		return
	item.give_to(player_data)
	EventBus.item_pickup_show.emit(item)
	await EventBus.item_pickup_dismissed
	print("NPC gave item %s" % item.item_name)
