extends Node

# === Globals ===
const GRID_SIZE: Vector2 = GameMaster.GRID_SIZE
const CELL_SIZE: Vector2 = GameMaster.CELL_SIZE

var combatants: Dictionary
var queue: Array [Actor] = []

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		combatants[actor] = {}
		var current_hp = actor.data.max_hp
		combatants[actor]["HP"] = current_hp
		combatants[actor]["AP"] = 3
		combatants[actor]["Coords"] = Vector2i(actor.position / CELL_SIZE)

func add_portrait(actor: Actor, portrait) -> void:
	combatants[actor]["portrait"] = portrait
