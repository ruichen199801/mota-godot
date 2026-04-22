class_name NpcDialogBehavior
extends NpcBehavior

@export var dialogs: Array[NpcDialogData] = []

## If set, replaces dialogs after the first interaction.
@export var dialogs_after_first_interaction: Array[NpcDialogData] = []


func execute(npc_name: String, npc_frames: SpriteFrames, 
			 _player_data: PlayerData) -> void:
	EventBus.npc_dialog_opened.emit(npc_name, npc_frames, dialogs)
	await EventBus.npc_dialog_closed
	
	if not dialogs_after_first_interaction.is_empty():
		dialogs = dialogs_after_first_interaction
		dialogs_after_first_interaction = []
