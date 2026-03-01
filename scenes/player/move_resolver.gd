extends Node

var player: Node2D
var is_resolving := false


func _ready() -> void:
	EventBus.move_requested.connect(_on_move_requested)


func _on_move_requested(direction: Vector2i) -> void:
	if is_resolving:
		return
		
	var target: Vector2i = player.grid_pos + direction
	
	# Boundary check
	if not FloorManager.is_in_bounds(target):
		EventBus.move_resolved.emit(target, false)
		return
		
	var entity: TileEntity = FloorManager.get_entity(target)
	
	# Empty ground
	if entity == null:
		EventBus.move_resolved.emit(target, true)
		return
		
	# Non-interact cells: always block silently
	if not entity.is_interact_cell(target):
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
		EventBus.move_resolved.emit(target, true)
