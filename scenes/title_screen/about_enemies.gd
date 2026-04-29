extends Control

@onready var back_button: Button = %BackButton

const TITLE_SCENE_PATH := "res://scenes/title_screen/title_screen.tscn"


func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
