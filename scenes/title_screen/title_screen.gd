extends Control

@onready var title_row: HBoxContainer = %TitleRow
@onready var version_label: Label = %VersionLabel
@onready var start_button: Button = %StartButton
@onready var info_button: Button = %InfoButton
@onready var enemies_button: Button = %EnemiesButton
@onready var fade_rect: ColorRect = %FadeRect

const FADE_DURATION := 0.8
const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"

const TITLE_SLIDE_OFFSET := 80.0
const TITLE_SLIDE_DURATION := 1.0
const VERSION_SLIDE_OFFSET := 40.0
const VERSION_SLIDE_DURATION := 0.6


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	info_button.pressed.connect(_on_info_button_pressed)
	enemies_button.pressed.connect(_on_enemies_button_pressed)
	_play_title_intro()


func _play_title_intro() -> void:
	version_label.modulate.a = 0.0

	title_row.position.x -= TITLE_SLIDE_OFFSET
	var title_tween := create_tween()
	title_tween.tween_property(title_row, "position:x",
		title_row.position.x + TITLE_SLIDE_OFFSET, TITLE_SLIDE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await title_tween.finished

	version_label.position.x -= VERSION_SLIDE_OFFSET
	var version_tween := create_tween()
	version_tween.set_parallel(true)
	version_tween.tween_property(version_label, "position:x",
		version_label.position.x + VERSION_SLIDE_OFFSET, VERSION_SLIDE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	version_tween.tween_property(version_label, "modulate:a",
		1.0, VERSION_SLIDE_DURATION)


func _on_start_button_pressed() -> void:
	start_button.disabled = true
	info_button.disabled = true
	enemies_button.disabled = true
	
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

	var main_scene: PackedScene = load(MAIN_SCENE_PATH)
	var main_instance := main_scene.instantiate()
	var root := get_tree().root
	root.add_child(main_instance)
	root.remove_child(self)
	queue_free()


func _on_info_button_pressed() -> void:
	pass


func _on_enemies_button_pressed() -> void:
	pass
