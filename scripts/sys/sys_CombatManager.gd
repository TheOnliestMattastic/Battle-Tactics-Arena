class_name CombatManager
extends Node

@onready var game_master: GameMaster = $".."
@onready var display_manager: DisplayManager = %UI
@onready var grid_map: Grid = %GridMap

func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: Manifest.combatants[actor]["init"] = Dice.roll_d10() + actor.data.spd
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])

func initiate_turn(queue: Array[Actor]) -> void:
	queue[0].active = true

func get_cells_in_range(actor) -> Array:
	var start_pos = Vector2i(actor.position) / GameMaster.CELL_SIZE
	var astar = grid_map.astar
	var in_range = actor.data.spd
	var cells = []
	
	grid_map.toggle_obstacle(start_pos, false) # mark starting cell as walkable
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var cell := Vector2i(x,y)
			var path = astar.get_id_path(start_pos, cell)
			if path.size() > 0 and path.size() - 1 <= in_range and not astar.is_point_solid(cell): cells.append(cell)
	grid_map.toggle_obstacle(start_pos, true) # reset starting cell as unwalkable
	return cells

func get_targets_in_range(actor, limit: int = 1, is_friendly: bool = false) -> Array:
	var origin = Vector2i(actor.position) / GameMaster.CELL_SIZE
	var targets: Array[Vector2i] = []
	var alignment = actor.data.alignment
	
	for x in range(-limit, limit + 1):
		for y in range(-limit, limit + 1):
			var distance = abs(x) + abs(y)
			if distance == 0 or distance > limit: continue
			var target_pos = origin + Vector2i(x, y)
			if not grid_map.astar.is_in_bounds(target_pos.x, target_pos.y): continue
			if not grid_map.astar.is_point_solid(target_pos): continue
			var target = Manifest.gridmap.get(target_pos).occupant
			if target:
				var same_alignment = (alignment == target.data.alignment)
				if is_friendly == same_alignment: targets.append(target_pos)
	return targets

func roll_for_attack(attacker: Actor, defender: Actor) -> Dictionary:
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
	return results

func roll_for_damage(attacker: Actor, defender: Actor) -> Dictionary:
	var results: Dictionary
	var damage_mod = attacker.data.pwr
	var damage_roll = Dice.roll_dice(damage_mod, 4)
	var deflected = defender.data.def
	results["attacker"] = attacker
	results["defender"] = defender
	results["raw"] = damage_roll
	results["deflected"] = deflected
	results["incoming"] = max(int(damage_roll - deflected), 0)
	return results

func apply_damage(results: Dictionary) -> void:
	var damage = results.get("incoming")
	var defender = results.get("defender")
	var hp = Manifest.combatants[defender]["HP"]
	var result = hp - damage
	if result > 0 : 
		Manifest.combatants[defender]["HP"] = result
	else: 
		Manifest.combatants[defender]["HP"] = 0
		game_master.actor_defeated(defender)

func spend_ap(actor: Actor, ammount: int = 1) -> void:
	print(Manifest.combatants[actor]["AP"])
	Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - 1
	return print(Manifest.combatants[actor]["AP"])
