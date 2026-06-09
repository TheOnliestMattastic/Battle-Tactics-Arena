class_name AbilityHeal
extends AbilityData

func stage(caster: Actor, astar: AStarGrid2D) -> void:
	var targets = GridMath.get_targets_in_range(caster, cast_range, astar, true)
	Grid.highlight_cells(targets, "green")


func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var results: Dictionary
	var target: Actor = Manifest.gridmap[coords].occupant
	if target == null or target.data.alignment != caster.data.alignment: # return if invalid target
		results["success"] = false
		results["message"] = "Invalid target."
		return results
		
	var ammount: int = int(caster.data.pwr * base_pwr)
	results = CombatManager.stage_heal_results(caster, target, ammount)
	CombatManager.spend_ap(caster, ap_cost)
	return results
