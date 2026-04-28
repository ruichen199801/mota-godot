class_name AnywhereDoorUI
extends Control

@onready var count_label: Label = %CountLabel


func _ready() -> void:
	visible = false
	EventBus.anywhere_door_ui_requested.connect(_on_anywhere_door_ui_requested)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		visible = false
		EventBus.anywhere_door_ui_closed.emit(true)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		visible = false
		EventBus.anywhere_door_ui_closed.emit(false)
		get_viewport().set_input_as_handled()


func _on_anywhere_door_ui_requested(uses: int) -> void:
	count_label.text = str(uses)
	visible = true
