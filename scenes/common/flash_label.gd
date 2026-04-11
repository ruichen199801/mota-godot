extends Label

@export var min_alpha: float = 0.3
@export var fade_duration: float = 0.8

var _tween: Tween


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if visible:
		_start()


func _start() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_loops()
	_tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	_tween.tween_property(self, "modulate:a", min_alpha, fade_duration)


func _on_visibility_changed() -> void:
	if visible:
		_start()
	elif _tween:
		_tween.kill()
		_tween = null
