class_name HealAbility
extends AbilityData

@export var modifier: float = 1.75

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var results: Dictionary
	var target = Manifest.gridmap[coords].occupant
	if target == null: # return if no target
		results["success"] = false
		results["message"] = "Invalid target."
		return results
	
	
	
	
	return results
