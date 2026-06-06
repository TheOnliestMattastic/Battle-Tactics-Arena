class_name CombatManager
extends Node

@onready var game_master: GameMaster = $".."
@onready var display_manager: DisplayManager = %UI
@onready var grid_map: Grid = %GridMap

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: 
		Manifest.combatants[actor]["init"] = Dice.roll_d20() + actor.data.spd
		Manifest.combatants[actor]["AP"] = min((Manifest.combatants[actor]["AP"] + 3), 5)
		actor.delayed = false
		actor.moved = false
		actor.attacked = false
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])

static func roll_for_attack(attacker: Actor, defender: Actor) -> Dictionary:
	var results: Dictionary
	var hit_mod = attacker.data.dex
	var evasion_mod = defender.data.dex + defender.data.spd
	var hit_roll = Dice.roll_dice_plus(2, 6, hit_mod)
	var evasion_roll = Dice.roll_dice_plus(1, 6, evasion_mod)
	results["success"] = hit_roll >= evasion_roll
	results["attacker"] = attacker
	results["defender"] = defender
	results["hit"] = hit_roll
	results["evasion"] = evasion_roll
	if not results["success"]: results["message"] = "Missed"
	return results

static func roll_for_damage(attacker: Actor, defender: Actor) -> Dictionary:
	var results: Dictionary
	var damage_mod = attacker.data.pwr
	var damage_roll = Dice.roll_dice(damage_mod, 4)
	results = stage_damage_results(attacker, defender, damage_roll)
	return results

static func stage_damage_results(attacker: Actor, defender: Actor, damage: int) -> Dictionary:
	var results: Dictionary
	var deflected: int = defender.data.def
	results["success"] = true
	results["attacker"] = attacker
	results["defender"] = defender
	results["raw"] = damage
	results["deflected"] = deflected
	results["damage"] = max(int(damage - deflected), 0)	
	return results

func apply_damage(results: Dictionary) -> void:
	var damage = results.get("damage")
	var defender = results.get("defender")
	var hp = Manifest.combatants[defender]["HP"]
	var result = hp - damage
	if result > 0 : 
		Manifest.combatants[defender]["HP"] = result
	else: 
		Manifest.combatants[defender]["HP"] = 0
		game_master.actor_defeated(defender)

static func spend_ap(actor: Actor, ammount: int = 1) -> void:
	if has_enough_ap(actor, ammount): Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - ammount
	else: print("[I AM ERROR] spend_ap edge was activated!")

static func has_enough_ap(actor: Actor, ammount: int = 1) -> bool:
	return Manifest.combatants[actor]["AP"] >= ammount
