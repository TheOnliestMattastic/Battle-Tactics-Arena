class_name TurnManager
extends Node

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue:
		Manifest.combatants[actor]["init"] = Dice.roll_d10() + actor.data.spd
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])

static func initiate_turn(queue: Array[Actor]) -> void:
	queue[0].active = true
