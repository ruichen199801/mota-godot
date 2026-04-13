class_name NpcDialogData
extends Resource

enum Speaker { NPC, PLAYER }

@export var speaker: Speaker = Speaker.NPC
@export_multiline var text: String
