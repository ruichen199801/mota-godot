class_name NpcDialogBehavior
extends NpcBehavior

@export var dialogs: Array[NpcDialogData] = []


func execute(npc_name: String, npc_frames: SpriteFrames, 
			 _player_data: PlayerData) -> void:
	EventBus.npc_dialog_opened.emit(npc_name, npc_frames, dialogs)
	await EventBus.npc_dialog_closed
