extends Node2D

@onready var floor_container: Node2D = $GameArea/FloorContainer
@onready var player: Node2D = $GameArea/Player
@onready var move_resolver: Node = $MoveResolver
@onready var active_item_handler: Node = $ActiveItemHandler
@onready var battle_handler: Node = $BattleHandler
@onready var hud: Control = $UILayer/HUD
@onready var shop_ui: ShopUI = $UILayer/ShopUI
@onready var battle_ui: BattleUI = $UILayer/BattleUI


func _ready() -> void:
	move_resolver.player = player
	active_item_handler.player = player
	battle_handler.player = player
	battle_handler.battle_ui = battle_ui
	player.init(FloorManager.START_POS)
	
	_load_all_floors()
	_switch_to_floor(FloorManager.START_FLOOR_ID)
	
	hud.bind_player(player.data, player.get_icon())
	EventBus.floor_change_requested.connect(_on_floor_change)
	EventBus.shop_opened.connect(_on_shop_opened)


func _load_all_floors() -> void:
	for floor_type in FloorManager.FLOOR_RANGES:
		var bounds: Array = FloorManager.FLOOR_RANGES[floor_type]
		for floor_num in range(bounds[0], bounds[1] + 1):
			var floor_id := FloorManager.create_floor_id(floor_type, floor_num)
			var path := FloorManager.get_floor_scene_path(floor_id)
			
			if not ResourceLoader.exists(path):
				continue
				
			var scene: PackedScene = load(path)
			var floor_node: Node2D = scene.instantiate()
			floor_container.add_child(floor_node)
			var floor_grid: Dictionary = floor_node.setup()
			FloorManager.add_floor(floor_id, floor_node, floor_grid)


func _on_floor_change(floor_id: String, spawn_pos: Vector2i) -> void:
	_switch_to_floor(floor_id)
	
	if not FloorManager.is_in_bounds(spawn_pos):
		push_error("Player spawn pos %s out of bounds on floor %s" % [spawn_pos, floor_id])
		return
	
	var entity := FloorManager.get_entity(spawn_pos)
	if entity != null and not entity.can_spawn_on():
		push_error("Player spawn pos %s blocked by %s on floor %s" % [
			spawn_pos, entity.name, floor_id
		])
		return
	
	player.place_at(spawn_pos)
	

func _switch_to_floor(floor_id: String) -> void:
	FloorManager.switch_to_floor(floor_id)
	hud.set_floor_display(floor_id)
	EventBus.floor_switched.emit(floor_id)


func _on_shop_opened(shop_entity: ShopEntity) -> void:
	shop_ui.open(shop_entity, player.data)
