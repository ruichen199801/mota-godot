class_name ItemConfirmUI
extends Control

@onready var name_label: Label = %NameLabel
@onready var count_label: Label = %CountLabel
@onready var icon_rect: TextureRect = %ItemIcon


func _ready() -> void:
	visible = false
	EventBus.item_confirm_ui_requested.connect(_on_item_confirm_ui_requested)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		visible = false
		EventBus.item_confirm_ui_closed.emit(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		visible = false
		EventBus.item_confirm_ui_closed.emit(false)
		get_viewport().set_input_as_handled()


func _on_item_confirm_ui_requested(item_name: String, uses: int, icon: Texture2D) -> void:
	name_label.text = "%s X" % item_name
	count_label.text = str(uses)
	if icon:
		icon_rect.texture = icon
	visible = true
