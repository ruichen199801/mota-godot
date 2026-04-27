class_name NpcGoodEndingAction
extends NpcPostAction

@export var delay_sec: float


func apply(_grid_pos: Vector2i, _player_data: PlayerData) -> void:
	print("Triggered good ending")
	var tree := Engine.get_main_loop() as SceneTree
	if delay_sec > 0.0:
		await tree.create_timer(delay_sec).timeout
	tree.quit()
	# TODO: Go to good ending screen
