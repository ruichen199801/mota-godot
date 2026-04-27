class_name NpcBadEndingAction
extends NpcPostAction

@export var delay_sec: float


func apply(_grid_pos: Vector2i, _player_data: PlayerData) -> void:
	print("Triggered bad ending")
	var tree := Engine.get_main_loop() as SceneTree
	if delay_sec > 0.0:
		await tree.create_timer(delay_sec).timeout
	tree.quit()
	# TODO: Go to bad ending screen
