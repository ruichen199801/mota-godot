class_name ItemPickupUI
extends Control

@onready var name_label: Label = %ItemNameLabel
@onready var desc_label: Label = %ItemDescLabel


func _ready() -> void:
	visible = false
	EventBus.item_pickup_show.connect(_on_item_pickup_show)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or \
	   (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		visible = false
		EventBus.item_pickup_dismissed.emit()


func _on_item_pickup_show(item_data: ItemData) -> void:
	if item_data.description:
		name_label.text = item_data.item_name + " :"
		desc_label.text = item_data.description		
	else:
		name_label.text = item_data.item_name
		desc_label.text = ""
	visible = true
