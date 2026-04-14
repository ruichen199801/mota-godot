class_name NpcDialogUI 
extends Control

@onready var npc_panel: PanelContainer = %NpcPanel
@onready var npc_avatar_sprite: AnimatedSprite2D = %NpcAvatarSprite
@onready var npc_name_label: Label = %NpcNameLabel
@onready var npc_text_label: RichTextLabel = %NpcTextLabel
@onready var npc_dismiss_hint: Label = %NpcDismissHint

@onready var player_panel: PanelContainer = %PlayerPanel
@onready var player_avatar_icon: TextureRect = %PlayerAvatarIcon
@onready var player_name_label: Label = %PlayerNameLabel
@onready var player_text_label: RichTextLabel = %PlayerTextLabel
@onready var player_dismiss_hint: Label = %PlayerDismissHint

var _dialogs: Array[NpcDialogData] = []
var _current_index: int = 0
var _npc_name: String


func _ready() -> void:
	visible = false
	npc_panel.visible = false
	player_panel.visible = false
	EventBus.npc_dialog_opened.connect(_on_dialog_opened)


func _on_dialog_opened(npc_name: String, npc_frames: SpriteFrames,
					   dialogs: Array) -> void:
	_npc_name = npc_name
	_dialogs.assign(dialogs)
	_current_index = 0

	if npc_frames:
		npc_avatar_sprite.sprite_frames = npc_frames
		npc_avatar_sprite.play("idle")

	var player_node := get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_method("get_icon"):
		player_avatar_icon.texture = player_node.get_icon()

	visible = true
	_show_current_dialog()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept") or \
	   (event is InputEventMouseButton and event.pressed \
	   and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	_current_index += 1
	if _current_index >= _dialogs.size():
		_close()
	else:
		_show_current_dialog()


func _show_current_dialog() -> void:
	var dialog: NpcDialogData = _dialogs[_current_index]

	match dialog.speaker:
		NpcDialogData.Speaker.NPC:
			npc_name_label.text = _npc_name
			npc_text_label.text = dialog.text
			npc_panel.visible = true
			player_panel.visible = false
			
		NpcDialogData.Speaker.PLAYER:
			player_text_label.text = dialog.text
			player_panel.visible = true
			npc_panel.visible = false


func _close() -> void:
	visible = false
	npc_panel.visible = false
	player_panel.visible = false
	EventBus.npc_dialog_closed.emit()
