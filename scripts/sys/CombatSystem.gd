class_name CombatSystem
extends Node

@onready var grid_map: Grid = %GridMap

func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue:
		Manifest.combatants[actor]["init"] = Dice.roll_d10() + actor.data.spd
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
			if path.size() > 0 and path.size() - 1 <= in_range and not astar.is_point_solid(cell):
				cells.append(cell)
	grid_map.toggle_obstacle(start_pos, true) # reset starting cell as unwalkable
	return cells

func get_targets_in_range(actor, limit: int = 2) -> Array:
	var origin = Vector2i(actor.position) / GameMaster.CELL_SIZE
	var targets: Array[Vector2i] = []
	for x in range(-limit, limit + 1):
		for y in range(-limit, limit + 1):
			var offset = Vector2i(x, y)
			if abs(x) + abs(y) <= limit and offset != Vector2i.ZERO:
				var target_pos = origin + offset
				if grid_map.astar.is_in_bounds(target_pos.x, target_pos.y) and grid_map.astar.is_point_solid(target_pos):
					targets.append(target_pos)
	return targets
