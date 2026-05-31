extends Node

# === Globals ===
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)

var combatants: Dictionary
var queue: Array [Actor] = []

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		combatants[actor] = {}

func add_portrait(actor: Actor, portrait) -> void:
	combatants[actor]["portrait"] = portrait
