extends Node

var player: Node2D


func _input(event: InputEvent) -> void:
	# Blocks all item handler input while any entity interaction is in progress
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
	var uses := pd.get_item_uses("anywhere_door")
	if not pd.has_item("anywhere_door") or uses <= 0:
		return
	
	var target: Vector2i = player.grid_pos + player.facing
	var entity := FloorManager.get_entity(target)
	
	# Can place on lava or replaceable walls
	var can_place: bool = (entity is LavaEntity) or (entity is WallEntity and entity.replaceable)
	if not can_place:
		return
		
	var item_data: ItemData = pd.get_item_data("anywhere_door")
	
	player.is_busy = true
	EventBus.item_confirm_ui_requested.emit(item_data.item_name, uses, item_data.icon)
	var confirmed: bool = await EventBus.item_confirm_ui_closed
	
	if confirmed:
		pd.use_item("anywhere_door")
		var door_scene: PackedScene = preload("res://entities/door_entity.tscn")
		var door: DoorEntity = FloorManager.spawn_entity(door_scene, target)
		door.door_type = DoorEntity.DoorType.YELLOW
	
	player.is_busy = false
	

func _use_divine_sword_token(pd: PlayerData) -> void:
	var uses := pd.get_item_uses("divine_sword_token")
	if not pd.has_item("divine_sword_token") or uses <= 0:
		return
	
	var target: Vector2i = player.grid_pos + player.facing
	var entity := FloorManager.get_entity(target)
	
	var is_valid_enemy: bool = entity is EnemyEntity and not entity.data.immune_to_divine_sword
	var is_valid_npc: bool = entity is NpcEntity and entity.data.divine_sword_targetable
	if not is_valid_enemy and not is_valid_npc:
		return
	
	var item_data: ItemData = pd.get_item_data("divine_sword_token")
	
	player.is_busy = true
	EventBus.item_confirm_ui_requested.emit(item_data.item_name, uses, item_data.icon)
	var confirmed: bool = await EventBus.item_confirm_ui_closed
	
	if confirmed:
		pd.use_item("divine_sword_token")
		var slime_data: EnemyData = preload("res://resources/enemies/green_slime/green_slime.tres")
		
		if is_valid_enemy:
			entity.replace_with(slime_data)
		elif is_valid_npc:
			var enemy_scene: PackedScene = preload("res://entities/enemy_entity.tscn")
			var enemy: EnemyEntity = FloorManager.spawn_entity(enemy_scene, target)
			enemy.data = slime_data
			
	player.is_busy = false


func _use_floor_transport(pd: PlayerData) -> void:
	if not pd.has_item("golden_feather"):
		return
	if not FloorManager.is_transport_usable(FloorManager.current_floor_id):
		return
	EventBus.floor_transport_requested.emit()
	

func _use_mind_mirror(pd: PlayerData) -> void:
	if not pd.has_item("mind_mirror"):
		return
	player.is_busy = true
	EventBus.mind_mirror_requested.emit()
	await EventBus.mind_mirror_closed
	player.is_busy = false
