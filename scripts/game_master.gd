class_name GameMaster 
extends Node

# === GLOBALS ===
const MAP_SIZE: Vector2 = Vector2(768, 320)
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)

# === Queue config ===
@onready var vanguard: Array = $"../Actors/Vanguard".get_children()
@onready var flank: Array = $"../Actors/Flank".get_children()

# === Systems config ===
@onready var display_manager: DisplayManager = %UI

# === Lists ===
var queue: Array[Actor] = []
var combatants: Dictionary = {}
var portraits: Dictionary = {}
var initiative: Dictionary = {}

func _ready() -> void:
	queue.append_array(vanguard)
	queue.append_array(flank)
	initiative = TurnManager.roll_for_init(queue)
	display_manager.log_init(initiative)
	portraits = display_manager.display_queue(queue)
	for actor in queue: # Populate combatants dictionary
		combatants[actor.data.name] = actor
	TurnManager.initiate_turn(queue)

func _process(delta: float) -> void:
	for combatant in combatants:
		if combatants[combatant].target:
			display_manager.display_target(combatants[combatant])
