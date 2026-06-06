class_name SnipeAbility
extends AbilityData

@export var modifier: float = 1.5

func stage(caster: Actor, astar: AStarGrid2D) -> Dictionary:
	var results: Dictionary
	var targets = GridMath.get_targets_in_range(caster, cast_range, astar)
	Grid.highlight_cells(targets, "red")
	results["success"] = true
	return results

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	# setup 
	var results: Dictionary
	var target = Manifest.gridmap[coords].occupant
	if target == null: # return if no target
		results["success"] = false
		results["message"] = "Invalid target."
		return results
	
	# return if missed
	results = CombatManager.roll_for_attack(caster, target)
	if not results["success"]: return results
	
	# calculate damage
	var base_damage = int(caster.data.pwr * base_pwr)
	var caster_coords = Vector2i(caster.position) / GameMaster.CELL_SIZE
	var distance = caster_coords.distance_to(coords)
	var raw = int(Dice.roll_dice(base_damage, 4) + (distance * modifier))
	results = CombatManager.stage_damage_results(caster, target, raw)
	return results
