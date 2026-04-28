extends Node

# Player movement events
signal move_requested(direction: Vector2i)
signal move_resolved(target_pos: Vector2i, approved: bool)

# Floor events
signal floor_change_requested(floor_id: String, spawn_pos: Vector2i)
signal floor_change_completed

# Item events
signal floor_transport_requested
signal floor_transport_selected(floor_id: String, spawn_pos: Vector2i)
signal floor_transport_closed

signal mind_mirror_requested
signal mind_mirror_closed

signal item_pickup_show(item_data: ItemData)
signal item_pickup_dismissed

signal anywhere_door_ui_requested(uses: int)
signal anywhere_door_ui_closed(confirmed: bool)

# Shop events
signal shop_opened(shop_entity: ShopEntity)
signal shop_closed

# Battle events
signal battle_requested(enemy_entity: EnemyEntity, player_data: PlayerData)
signal battle_finished # can be fired from all battle results
signal enemy_defeated(enemy_data: EnemyData) # WIN result only

# NPC events
signal npc_dialog_opened(npc_name: String, npc_frames: SpriteFrames, dialogs: Array)
signal npc_dialog_closed

signal npc_merchant_opened(npc_name: String, npc_frames: SpriteFrames, merchant_data: NpcMerchantData)
signal npc_merchant_closed(one_time_trade_made: bool)
