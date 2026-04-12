extends Node

var player: Node2D
var is_resolving := false


func _ready() -> void:
	EventBus.move_requested.connect(_on_move_requested)


func _on_move_requested(direction: Vector2i) -> void:
	if is_resolving:
		return
		
	var target: Vector2i = player.grid_pos + direction
	var entity: TileEntity = FloorManager.get_entity(target)
	
	# Boundary check
	if entity == null and not FloorManager.is_in_bounds(target):
		var portal := _get_matching_portal(player.grid_pos, direction)
		if portal != null:
			is_resolving = true
			EventBus.floor_change_requested.emit(portal.dest_floor_id, portal.dest_pos)
			await EventBus.floor_change_completed
			is_resolving = false
			
		EventBus.move_resolved.emit(target, false)
		return
	
	# Empty ground
	if entity == null:
		_approve_move(target)
		return
		
	# Non-interact cells: always block silently
	if not entity.is_interact_cell(target, direction):
		EventBus.move_resolved.emit(target, false)
		return
		
	# Interact cells
	var pd: PlayerData = player.data
	
	if entity.is_blocking(pd):
		if entity.is_async():
			is_resolving = true
			await entity.on_block(pd)
			is_resolving = false
		else:
			entity.on_block(pd)
			print("Player blocked by %s" % entity.get_script().get_global_name())
		EventBus.move_resolved.emit(target, false)
	else:
		if entity.is_async():
			is_resolving = true
			await entity.on_enter(pd)
			is_resolving = false
		else:
			entity.on_enter(pd)
		_approve_move(target)


func _approve_move(target: Vector2i) -> void:
	player.data.apply_poison()
	EventBus.move_resolved.emit(target, true)


## Checks if the player's current cell has an edge portal matching the move direction.
func _get_matching_portal(pos: Vector2i, direction: Vector2i) -> EdgePortalEntity:
	var portal := FloorManager.get_portal(pos)
	if portal != null and portal.trigger_direction == direction:
		return portal
	return null
