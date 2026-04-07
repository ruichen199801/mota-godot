extends Node

var player: Node2D


func _input(event: InputEvent) -> void:
	if player == null or player.is_busy:
		return
	
	var pd: PlayerData = player.data
	
	if event.is_action_pressed("use_anywhere_door"):
		_use_anywhere_door(pd)
	elif event.is_action_pressed("use_divine_sword_token"):
		_use_divine_sword_token(pd)
	elif event.is_action_pressed("use_floor_transport"):
		_use_floor_transport(pd)
	elif event.is_action_pressed("use_mind_mirror"):
		_use_mind_mirror(pd)
	

func _use_anywhere_door(pd: PlayerData) -> void:
	if not pd.has_item("anywhere_door") or pd.get_item_uses("anywhere_door") <= 0:
		return
	
	var target: Vector2i = player.grid_pos + player.facing
	var entity := FloorManager.get_entity(target)
	
	# Can place on: empty ground, lava, or replaceable walls
	var can_place := false
	if entity == null and FloorManager.is_in_bounds(target):
		can_place = true
	elif entity is LavaEntity:
		can_place = true
	elif entity is WallEntity and entity.replaceable:
		can_place = true
	
	if can_place:
		pd.use_item("anywhere_door")

		# Place yellow door
		var door_scene: PackedScene = preload("res://entities/door_entity.tscn")
		var door: DoorEntity = FloorManager.spawn_entity(door_scene, target)
		door.door_type = DoorEntity.DoorType.YELLOW
		

func _use_divine_sword_token(pd: PlayerData) -> void:
	if not pd.has_item("divine_sword_token") or pd.get_item_uses("divine_sword_token") <= 0:
		return
	
	var target: Vector2i = player.grid_pos + player.facing
	var entity := FloorManager.get_entity(target)
	
	if entity is EnemyEntity:
		pd.use_item("divine_sword_token")
		# Replace with green slime
		var slime_data: EnemyData = preload("res://resources/enemies/green_slime/green_slime.tres")
		entity.replace_with(slime_data)


func _use_floor_transport(pd: PlayerData) -> void:
	if not pd.has_item("golden_feather"):
		return
	EventBus.floor_transport_requested.emit()
	# TODO: Handle this event in main.gd to open floor selection UI
	

func _use_mind_mirror(pd: PlayerData) -> void:
	if not pd.has_item("mind_mirror"):
		return
	player.is_busy = true # prevent player moving
	EventBus.mind_mirror_requested.emit()
	await EventBus.mind_mirror_closed
	player.is_busy = false
