extends Node

var combatants: Dictionary
var queue: Array [Actor] = []

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		combatants[actor] = {}

func add_portrait(actor: Actor, portrait) -> void:
	combatants[actor]["portrait"] = portrait
	#print(actor.data.name)
	#print(portrait)
	#print(combatants)
