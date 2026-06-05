class_name SnipeAbility
extends AbilityData

@export var modifier: float = 1.5

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
	var total_damage = int(Dice.roll_dice(base_damage, 4) + (distance * modifier))
	results["damage"] = total_damage
	return results
