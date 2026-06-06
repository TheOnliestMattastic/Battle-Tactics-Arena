class_name HealAbility
extends AbilityData

@export var modifier: float = 1.75

func stage(caster: Actor, astar: AStarGrid2D) -> Dictionary:
	var results: Dictionary
	var targets = GridMath.get_targets_in_range(caster, cast_range, astar, true)
	Grid.highlight_cells(targets, "green")
	results["success"] = true
	return results

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var results: Dictionary
	var target: Actor = Manifest.gridmap[coords].occupant
	if target == null or target.data.alignment != caster.data.alignment: # return if invalid target
		results["success"] = false
		results["message"] = "Invalid target."
		return results
	
	
	
	
	
	return results
