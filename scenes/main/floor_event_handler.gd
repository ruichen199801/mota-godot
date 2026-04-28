## Handles one-time floor tile changes triggered by game events.
extends Node

enum Event {
	MAIN_20_ON_FAKE_PRINCESS_DEFEAT,
	BASE_25_ON_FAKE_PRINCESS_DEFEAT,
	BASE_24_ON_FIRST_ARRIVAL_POST_BOSS_FIGHT,
	MOTA_5_ON_EMBLEM_PICKUP,
}

var _remaining_events: Array[Event] = []


func _ready() -> void:
	_remaining_events = [
		Event.MAIN_20_ON_FAKE_PRINCESS_DEFEAT,
		Event.BASE_25_ON_FAKE_PRINCESS_DEFEAT,
		Event.MOTA_5_ON_EMBLEM_PICKUP,
	]
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.item_pickup_show.connect(_on_item_pickup_show)


func _on_enemy_defeated(enemy_data: EnemyData) -> void:
	var floor_id := FloorManager.current_floor_id
	if floor_id == "main_20" and enemy_data.enemy_id == "fake_princess":
		await _try_handle(
			Event.MAIN_20_ON_FAKE_PRINCESS_DEFEAT,
			_main_20_post_fake_princess_defeat)
	
	if floor_id == "base_25" and enemy_data.enemy_id == "green_slime":
		await _try_handle(
			Event.BASE_25_ON_FAKE_PRINCESS_DEFEAT,
			_base_25_post_fake_princess_defeat)
		

func on_floor_arrived(floor_id: String) -> void:
	if floor_id == "base_24":
		await _try_handle(
			Event.BASE_24_ON_FIRST_ARRIVAL_POST_BOSS_FIGHT,
			_base_24_post_boss_fight_arrival)


func _on_item_pickup_show(item_data: ItemData) -> void:
	var floor_id := FloorManager.current_floor_id
	if floor_id == "mota_5" and item_data.item_id in \
		["sage_emblem_lv0", "overlord_emblem_lv0", "hero_emblem_lv0"]:
		await _try_handle(
			Event.MOTA_5_ON_EMBLEM_PICKUP,
			_mota_5_post_emblem_pickup.bind(item_data.item_id))


# --- Events ---

## 1. Player has conversation with fake princess NPC
## 2. Fake princess NPC spawns wall to block player from retreat, and turns into enemy
## 3. Player defeats fake princess enemy
## 4. Fake princess dialog shows
## 5. Wall gone, reward items and down stair show
func _main_20_post_fake_princess_defeat() -> void:
	await _show_dialogs(
		[preload("res://resources/npcs/dialogs/main_20_post_boss_dialog.tres")],
		"公主",
		preload("res://resources/npcs/princess_frames.tres"))

	FloorManager.replace_floor("main_20", "res://floors/main_20_post_boss.tscn")


## 1. Player uses divine sword token to turn fake princess NPC into a green slime
## 2. Player defeats green slime
## 3. Player and monster boss dialogs show
## 4. Up stair shows, base_24 floor changes, floor transport permanently disabled
func _base_25_post_fake_princess_defeat() -> void:
	await _show_dialogs(
		[
			preload("res://resources/npcs/dialogs/base_25_post_boss_dialog_1.tres"), 
			preload("res://resources/npcs/dialogs/base_25_post_boss_dialog_2.tres"),
			preload("res://resources/npcs/dialogs/base_25_post_boss_dialog_3.tres"),
			preload("res://resources/npcs/dialogs/base_25_post_boss_dialog_4.tres"),
		],
		"魔物首领",
		preload("res://resources/npcs/monster_boss_frames.tres"),
		1.0)
		
	var stair_scene: PackedScene = preload("res://entities/stair_up_entity.tscn")
	var stair: StairEntity = FloorManager.spawn_entity_on_floor(
			stair_scene, "base_25", Vector2i(5, 0))
	stair.stair_direction = StairEntity.StairDirection.UP
	stair.dest_floor_id = "base_24"
	stair.dest_pos = Vector2i(5, 0)
		
	FloorManager.replace_floor("base_24", "res://floors/base_24_post_boss.tscn")
	FloorManager.disable_transport()
	_remaining_events.append(Event.BASE_24_ON_FIRST_ARRIVAL_POST_BOSS_FIGHT)


## 1. Player uses the stair from base_25 after boss fight
## 2. Player is placed at the updated base_24 floor
## 3. Player dialog shows
func _base_24_post_boss_fight_arrival() -> void:
	await _show_dialogs(
		[preload("res://resources/npcs/dialogs/base_24_post_boss_dialog.tres")],
		"", null, 1.0)


## 1. Player picks an emblem out of the three
## 2. Walls show to block paths to the other two unchosen emblems, self npc shows
func _mota_5_post_emblem_pickup(item_id: String) -> void:
	match item_id:
		"sage_emblem_lv0":
			FloorManager.spawn_wall("mota_5", Vector2i(5, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(10, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(5, 5), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(6, 6), Vector2i(1, 2))
		"overlord_emblem_lv0":
			FloorManager.spawn_wall("mota_5", Vector2i(0, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(10, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(4, 6), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(6, 6), Vector2i(1, 2))
		"hero_emblem_lv0":
			FloorManager.spawn_wall("mota_5", Vector2i(0, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(5, 1), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(4, 6), Vector2i(1, 2))
			FloorManager.spawn_wall("mota_5", Vector2i(5, 5), Vector2i(1, 2))
			
	var npc_scene: PackedScene = preload("res://entities/npc_entity.tscn")
	var npc: NpcEntity = FloorManager.spawn_entity_on_floor(npc_scene, "mota_5", Vector2i(5, 9))
	npc.data = preload("res://resources/npcs/self_npc.tres")
	

# --- Helpers ---

func _try_handle(event: Event, callback: Callable) -> void:
	if event not in _remaining_events:
		return
	_remaining_events.erase(event)
	await callback.call()


func _show_dialogs(dialogs: Array, npc_name: String = "", 
				   npc_frames: SpriteFrames = null, 
				   delay_sec: float = 0.0) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.is_busy = true

	if delay_sec > 0.0:
		await get_tree().create_timer(delay_sec).timeout

	EventBus.npc_dialog_opened.emit(npc_name, npc_frames, dialogs)
	await EventBus.npc_dialog_closed

	if player:
		player.is_busy = false
