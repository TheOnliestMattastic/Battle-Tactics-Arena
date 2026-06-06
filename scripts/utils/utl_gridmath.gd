extends Node

func get_targets_in_range(actor: Actor, limit: int, astar: AStarGrid2D, is_friendly: bool = false) -> Array:
	var origin = Vector2i(actor.position) / GameMaster.CELL_SIZE
	var targets: Array[Vector2i] = []
	var alignment = actor.data.alignment
	
	for x in range(-limit, limit + 1):
		for y in range(-limit, limit + 1):
			var distance = abs(x) + abs(y)
			if distance == 0 or distance > limit: continue
			var target_pos = origin + Vector2i(x, y)
			if not astar.is_in_bounds(target_pos.x, target_pos.y): continue
			if not astar.is_point_solid(target_pos): continue
			var target = Manifest.gridmap.get(target_pos).occupant
			if target:
				var same_alignment = (alignment == target.data.alignment)
				if is_friendly == same_alignment: targets.append(target_pos)
	return targets

func get_cells_in_range(actor: Actor, astar: AStarGrid2D) -> Array:
	var start_pos = Vector2i(actor.position) / GameMaster.CELL_SIZE
	var in_range = actor.data.spd
	var cells = []
	
	astar.set_point_solid(start_pos, false)
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var cell := Vector2i(x,y)
			var path = astar.get_id_path(start_pos, cell)
			if path.size() > 0 and path.size() - 1 <= in_range and not astar.is_point_solid(cell): cells.append(cell)
	astar.set_point_solid(start_pos, true) # reset starting cell as unwalkable
	return cells
