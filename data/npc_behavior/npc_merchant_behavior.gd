class_name NpcMerchantBehavior
extends NpcBehavior

@export var merchant: NpcMerchantData

## Set during execute(), read during run_post_actions().
## True when a one-time merchant completed a trade.
var _one_time_trade_made := false


func execute(npc_name: String, npc_frames: SpriteFrames, 
			 _player_data: PlayerData) -> void:
	EventBus.npc_merchant_opened.emit(npc_name, npc_frames, merchant)
	_one_time_trade_made = await EventBus.npc_merchant_closed


func run_post_actions(grid_pos: Vector2i, player_data: PlayerData) -> void:
	## Make sure remove or respawn action does not fire 
	## when player selects leave option without making a purchase
	if merchant.one_time and not _one_time_trade_made: 
		return
		
	await super.run_post_actions(grid_pos, player_data)
	
	## Show item pickup UI only when the trade is one-time, an item is traded, and the trade succeeded.
	## If the merchant is permanent, e.g. anywhere door refill, item pickup UI won't show.
	if _one_time_trade_made and merchant.options.size() > 0:
		var opt: ShopOptionData = merchant.options[0] # assumes only 1 item option
		if opt.item:
			EventBus.item_pickup_show.emit(opt.item)
			await EventBus.item_pickup_dismissed
