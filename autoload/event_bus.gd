extends Node

# Player movement events
signal move_requested(direction: Vector2i)
signal move_resolved(target_pos: Vector2i, approved: bool)

# Floor events
signal floor_change_requested(floor_id: String, spawn_pos: Vector2i)
signal floor_switched(floor_id: String)

# Item events
signal floor_transport_requested
signal mind_mirror_requested

# Shop events
signal shop_opened(shop_entity: ShopEntity)
signal shop_closed
