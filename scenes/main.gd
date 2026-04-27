extends Node2D

@onready var floor_container: Node2D = $GameArea/FloorContainer
@onready var player: Node2D = $GameArea/Player
@onready var move_resolver: Node = $MoveResolver
@onready var active_item_handler: Node = $ActiveItemHandler
@onready var battle_handler: Node = $BattleHandler
@onready var floor_event_handler: Node = $FloorEventHandler
@onready var hud: Control = $UILayer/HUD
@onready var shop_ui: ShopUI = $UILayer/ShopUI
@onready var battle_ui: BattleUI = $UILayer/BattleUI
@onready var mind_mirror_ui: MindMirrorUI = $UILayer/MindMirrorUI
@onready var floor_transport_ui: FloorTransportUI = $UILayer/FloorTransportUI
@onready var floor_transition_ui: FloorTransitionUI = $UILayer/FloorTransitionUI
@onready var npc_merchant_ui: Control = $UILayer/NpcMerchantUI


func _ready() -> void:
	move_resolver.player = player
	active_item_handler.player = player
	battle_handler.player = player
	battle_handler.battle_ui = battle_ui
	player.init(FloorManager.START_POS)
	
	_load_all_floors()
	FloorManager.switch_to_floor(FloorManager.START_FLOOR_ID)
	hud.set_floor_display(FloorManager.START_FLOOR_ID)
	
	hud.bind_player(player.data, player)
	EventBus.floor_change_requested.connect(_on_floor_change)
	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.mind_mirror_requested.connect(_on_mind_mirror_requested)
	EventBus.floor_transport_requested.connect(_on_floor_transport_requested)
	EventBus.floor_transport_selected.connect(_on_floor_transport_selected)
	EventBus.floor_transport_closed.connect(_on_floor_transport_closed)
	EventBus.npc_merchant_opened.connect(_on_npc_merchant_opened)
	
	_show_intro_dialog()


func _show_intro_dialog() -> void:
	if FloorManager.current_floor_id != "main_0":
		return
	player.is_busy = true
	await get_tree().create_timer(1.0).timeout
	var dialogs: Array = [preload("res://resources/npcs/dialogs/main_0_intro_dialog.tres")]
	EventBus.npc_dialog_opened.emit("", null, dialogs)
	await EventBus.npc_dialog_closed
	player.is_busy = false


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
			var result: Array = floor_node.setup() # [floor_grid, portal_map]
			FloorManager.add_floor(floor_id, floor_node, result[0], result[1])


# --- Floor change handlers ---
#
# Two paths trigger floor changes:
#
# 1. Entity path (e.g. stair):
#    player walks into entity -> move_resolver awaits on_block -> entity emits
#    floor_change_requested -> _transition_to_floor ->
#    emits floor_change_completed -> on_block returns.
#    Player movement is blocked by move resolver's async chain.
#
# 2. Transport path:
#    player opens transport UI -> is_busy set to true -> player selects floor ->
#    emits floor_transport_selected -> _transition_to_floor -> is_busy set to false.
#    Player movement is blocked by flipping is_busy manually.


## Shared floor change logic. Sequence of events:
##   1. Updates label to new floor name immediately
##   2. Plays fade-in overlay (old floor still visible underneath)
##   3. At full black: switches to the new floor and places the player
##   4. Plays fade-out overlay (new floor reveals)
func _transition_to_floor(floor_id: String, spawn_pos: Vector2i) -> void:
	hud.set_floor_display(floor_id)
	await floor_transition_ui.play()
	_place_on_floor(floor_id, spawn_pos)
	await floor_transition_ui.dismiss()
	

func _place_on_floor(floor_id: String, spawn_pos: Vector2i) -> void:
	FloorManager.switch_to_floor(floor_id)
	
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

		
## Handles floor change triggered by entities (stair) via move resolver.
func _on_floor_change(floor_id: String, spawn_pos: Vector2i) -> void:
	await _transition_to_floor(floor_id, spawn_pos)
	await floor_event_handler.on_floor_arrived(floor_id)
	EventBus.floor_change_completed.emit()


## Handles floor change triggered by floor transport UI.
func _on_floor_transport_requested() -> void:
	player.is_busy = true
	floor_transport_ui.open()


func _on_floor_transport_selected(floor_id: String, spawn_pos: Vector2i) -> void:
	await _transition_to_floor(floor_id, spawn_pos)
	player.is_busy = false
	
	
func _on_floor_transport_closed() -> void:
	player.is_busy = false
	
	
# --- UI handlers ---

func _on_shop_opened(shop_entity: ShopEntity) -> void:
	shop_ui.open(shop_entity, player.data)


func _on_mind_mirror_requested() -> void:
	mind_mirror_ui.open(player.data)


func _on_npc_merchant_opened(npc_name: String, npc_frames: SpriteFrames,
							 merchant_data: NpcMerchantData) -> void:
	npc_merchant_ui.open(npc_name, npc_frames, merchant_data, player.data)
