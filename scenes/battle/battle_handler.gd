extends Node

class AttackResult:
	var damage: int
	var dodged: bool
	var crit: bool
	
	func _init(_damage: int, _dodged: bool, _crit: bool) -> void:
		damage = _damage
		dodged = _dodged
		crit = _crit


enum BattleResult { WIN, LOSE, RETREAT }

var player: Node2D
var battle_ui: BattleUI

const TURN_DELAY := 0.1

var _player_data: PlayerData
var _enemy_data: EnemyData
var _enemy_entity: EnemyEntity
var _player_hp: int # snapshot player stats, only update back to player_data after battle finishes
var _enemy_hp: int
var _enemy_atk: int
var _enemy_def: int
var _retreat_requested := false


func _ready() -> void:
	EventBus.battle_requested.connect(_on_battle_requested)
	
	
func _on_battle_requested(enemy_entity: EnemyEntity, player_data: PlayerData) -> void:
	_enemy_entity = enemy_entity
	_player_data = player_data
	_enemy_data = enemy_entity.data
	_player_hp = player_data.hp
	_enemy_hp = _enemy_data.hp
	_enemy_atk = _enemy_data.atk
	_enemy_def = _enemy_data.def
	_retreat_requested = false
	
	_apply_adaptive_stats()
	
	battle_ui.retreat_pressed.connect(_on_retreat_pressed)
	battle_ui.show_battle(_player_data, _enemy_data, player.get_icon(), 
						 _enemy_atk, _enemy_def)
	
	var result: BattleResult = await _run_battle()
	
	match result:
		BattleResult.WIN:
			battle_ui.show_result(_enemy_data.xp_drop, _enemy_data.gold_drop)
			await battle_ui.wait_for_dismiss()
			_apply_battle_result(result)
			battle_ui.hide_battle()
			
		BattleResult.RETREAT:
			_apply_battle_result(result)
			battle_ui.hide_battle()
			
		BattleResult.LOSE:
			_apply_battle_result(result)
			await battle_ui.play_game_over()
			get_tree().quit()
	
	battle_ui.retreat_pressed.disconnect(_on_retreat_pressed)
	EventBus.battle_finished.emit()


# Calculates effective enemy atk/def based on special abilities. Called once before battle starts.
func _apply_adaptive_stats() -> void:
	if _enemy_data.adaptive_atk > 0:
		_enemy_atk = _player_data.def + _enemy_data.adaptive_atk
	
	if _enemy_data.mirror_atk and _player_data.atk > _enemy_data.atk:
		_enemy_atk = _player_data.atk
		
	if _enemy_data.harden and _player_data.atk > _enemy_data.def:
		_enemy_def = _player_data.atk - 1
		

func _run_battle() -> BattleResult:
	while true:
		# Retreat pressed during previous turn delay
		if _retreat_requested:
			return BattleResult.RETREAT
			
		# Player turn
		for i in range(_player_data.atk_times):
			var player_result := _resolve_attack(
				_player_data.atk, _enemy_def,
				_player_data.crit, _enemy_data.agi,
				_player_data.atk_crit
			)
			_enemy_hp -= player_result.damage
			battle_ui.update_hp(_player_hp, _enemy_hp)
		
			if player_result.dodged:
				await battle_ui.play_miss(true)
			else:
				var anim_name := _get_hit_anim_name(player_result.crit, _player_data.hit_frames)
				await battle_ui.play_hit(true, _player_data.hit_frames, anim_name)
			print(_format_log("player", player_result))

			if _enemy_hp <= 0:
				return BattleResult.WIN

		await get_tree().create_timer(TURN_DELAY).timeout
		
		# Retreat pressed during player animations or turn delay
		if _retreat_requested:
			return BattleResult.RETREAT

		# Enemy turn
		var effective_def := 0 if _enemy_data.ignore_def else _player_data.def
		
		for i in range(_enemy_data.atk_times):
			var enemy_result := _resolve_attack(
				_enemy_atk, effective_def,
				_enemy_data.crit, _player_data.agi,
				-_player_data.def_crit
			)
			_player_hp -= enemy_result.damage
			battle_ui.update_hp(_player_hp, _enemy_hp)
		
			if enemy_result.dodged:
				await battle_ui.play_miss(false)
			else:
				_update_player_state(enemy_result)
				var anim_name := _get_hit_anim_name(enemy_result.crit, _enemy_data.hit_frames)
				await battle_ui.play_hit(false, _enemy_data.hit_frames, anim_name)
			print(_format_log(_enemy_data.enemy_name, enemy_result))

			if _player_hp <= 0:
				return BattleResult.LOSE
		
		# Retreat pressed during enemy animations
		if _retreat_requested:
			return BattleResult.RETREAT

		await get_tree().create_timer(TURN_DELAY).timeout
		
	return BattleResult.LOSE
		

## Resolves a single attack from attacker to defender.
##
## Parameters:
##   atk           - attacker's attack
##   def           - defender's defense
##   crit_chance   - attacker's crit (% chance to deal double damage)
##   dodge_chance  - defender's agi (% chance to dodge the attack)
##   break_adjust  - modifier for minimum-damage threshold check:
##                   if base damage is 0 but atk + break_adjust >= def, deal 1 damage
##                   for player attacking enemy, break_adjust = +atk_crit 
##                   for enemy attacking player, break_adjust = -def_crit
func _resolve_attack(atk: int, def: int, 
					 crit_chance: int, dodge_chance: int, 
					 break_adjust: int) -> AttackResult:
	# Step 1: Dodge
	if randi() % 100 < dodge_chance:
		return AttackResult.new(0, true, false)

	# Step 2: Crit
	var is_crit := randi() % 100 < crit_chance

	# Step 3: Base damage
	var base_damage := maxi(atk - def, 0)

	# Step 4: Minimum damage via atk_crit or def_crit
	if base_damage == 0 and atk + break_adjust >= def:
		base_damage = 1

	# Step 5: Crit multiplier
	var final_damage := base_damage * (2 if is_crit else 1)
   
	return AttackResult.new(final_damage, false, is_crit)
	
	
func _update_player_state(result: AttackResult) -> void:
	if result.dodged:
		return
	
	# Do not update state if player is already in a debuff state
	if _player_data.state != PlayerData.State.NORMAL:
		return
		
	if _enemy_data.poison_chance > 0:
		if randi() % 100 < _enemy_data.poison_chance:
			_player_data.state = PlayerData.State.POISONED
			return
			
	if _enemy_data.weaken_chance > 0:
		if randi() % 100 < _enemy_data.weaken_chance:
			_player_data.state = PlayerData.State.WEAKENED


func _apply_battle_result(result: BattleResult) -> void:
	match result:
		BattleResult.WIN:
			_player_data.hp = _player_hp
			_player_data.gold += _enemy_data.gold_drop
			_player_data.xp += _enemy_data.xp_drop
			_enemy_entity.remove_from_grid()
			print("Battle won, gained %d gold, %d exp" % [_enemy_data.gold_drop, _enemy_data.xp_drop])
			
		BattleResult.LOSE:
			_player_data.hp = 0
			print("Game over")
			
		BattleResult.RETREAT:
			_player_data.hp = _player_hp
			print("Retreat from battle")


func _on_retreat_pressed() -> void:
	_retreat_requested = true


func _get_hit_anim_name(is_crit: bool, frames: SpriteFrames) -> String:
	if frames == null:
		return ""
	if is_crit and frames.has_animation("crit"):
		return "crit"
	if frames.has_animation("hit"):
		return "hit"
	return ""


func _format_log(attacker_name: String, result: AttackResult) -> String:
	if result.dodged:
		return "%s's attack dodged" % attacker_name
	elif result.crit:
		return "%s deals %d critical damage" % [attacker_name, result.damage]
	else:
		return "%s deals %d damage" % [attacker_name, result.damage]
