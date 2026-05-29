class_name TurnManager
extends Node

static func roll_for_init(queue: Array[Actor]) -> Dictionary:
	var initiative: Dictionary = {}
	for actor in queue:
		initiative[actor] = Dice.roll_d10() + actor.data.spd
	queue.sort_custom(func(a, b): return initiative[a] > initiative[b])
	return initiative

static func initiate_turn(queue: Array[Actor]) -> void:
	queue[0].active = true
