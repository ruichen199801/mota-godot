class_name LavaEntity
extends TileEntity

const DAMAGE := 50
const BURN_FADE_IN := 0.1
const BURN_HOLD := 0.2
const BURN_FADE_OUT := 0.2

@onready var burn_effect: Sprite2D = $BurnEffect


func is_blocking(pd: PlayerData) -> bool:
	if pd.has_item("ice_amulet"):
		return false
	return pd.hp <= DAMAGE
	
	
func on_enter(pd: PlayerData) -> void:
	if pd.has_item("ice_amulet"):
		remove_from_grid()
		return
	pd.hp -= DAMAGE
	
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_play_burn_effect(player)


func _play_burn_effect(player: Node2D) -> void:
	# Reparent the burn effect to player so it follows player movement
	remove_child(burn_effect)
	player.add_child(burn_effect)
	burn_effect.position = Vector2(16, 16)
	burn_effect.modulate.a = 0.0
	burn_effect.visible = true
	
	var tween := create_tween()
	tween.tween_property(burn_effect, "modulate:a", 1.0, BURN_FADE_IN)
	tween.tween_interval(BURN_HOLD)
	tween.tween_property(burn_effect, "modulate:a", 0.0, BURN_FADE_OUT)
	await tween.finished
	
	burn_effect.visible = false
	burn_effect.modulate.a = 1.0
	player.remove_child(burn_effect)
	add_child(burn_effect)
	burn_effect.position = Vector2.ZERO
