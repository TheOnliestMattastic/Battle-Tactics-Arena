extends AbilityData
class_name AbilitySunder

func stage(caster: Actor, astar: AStarGrid2D) -> void:
	var targets = GridMath.get_targets_in_range(caster, cast_range, astar)
	Grid.highlight_cells(targets, "red")

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	# setup
	var results: Dictionary
	var target: Actor = Manifest.gridmap[coords].occupant
	if target == null:
		results["success"] = false
		results["message"] = "Invalid target."
		return results
	
	# return if missed
	results = CombatManager.roll_for_attack(caster, target)
	if not results["success"]: return results
	
	var base_damage = int(caster.data.pwr * base_pwr)
	var raw = int(Dice.roll_dice(base_damage, 8))
	results = CombatManager.stage_damage_results(caster, target, raw)
	CombatManager.spend_ap(caster, ap_cost)
	return results
