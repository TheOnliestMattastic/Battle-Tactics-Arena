# manifest.gd
extends Node

# === Globals ===
const GRID_SIZE: Vector2 = GameMaster.GRID_SIZE
const CELL_SIZE: Vector2 = GameMaster.CELL_SIZE

# === Lists ===
var combatants: Dictionary
var gridmap: Dictionary
var portraits: Dictionary
var queue: Array [Actor]

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		var coords = Vector2i(actor.position / CELL_SIZE)
		gridmap[coords].occupant = actor
		combatants[actor] = {}
		combatants[actor]["HP"] = actor.data.max_hp
		combatants[actor]["AP"] = 3

func add_portrait(actor: Actor, portrait) -> void:
	portraits[portrait] = actor 

func remove_from_queue(actor: Actor) -> void:
	var coords = Vector2i(actor.position / CELL_SIZE)
	gridmap[coords].occupant = null
	combatants.erase(actor)
	for i in queue.size():
		if queue[i] == actor: 
			queue.pop_at(i)
			break
