class_name NpcMerchantBehavior
extends NpcBehavior

@export var merchant: NpcMerchantData

func execute(npc_name: String, npc_frames: SpriteFrames) -> void:
	EventBus.npc_merchant_opened.emit(npc_name, npc_frames, merchant)
	await EventBus.npc_merchant_closed
