extends Node

# Player movement events
signal move_requested(direction: Vector2i)
signal move_resolved(target_pos: Vector2i, approved: bool)

# Floor events
signal floor_change_requested(floor_id: int, spawn_pos: Vector2i)
signal floor_switched(floor_id: int)

# Player data change events
signal player_stats_changed
signal player_keys_or_gold_changed
signal player_state_changed
