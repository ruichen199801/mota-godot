class_name FloorTransitionUI 
extends Control

const FADE_IN_DURATION := 0.4
const HOLD_DURATION := 0.5
const FADE_OUT_DURATION := 0.4


func _ready() -> void:
	visible = false
	modulate.a = 0.0


func play() -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_IN_DURATION)
	await tween.finished


func dismiss() -> void:
	var tween := create_tween()
	tween.tween_interval(HOLD_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION)
	await tween.finished
	visible = false
