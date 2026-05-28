class_name GameMaster 
extends Node

# === GLOBALS ===
const MAP_SIZE: Vector2 = Vector2(768, 320)
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)
const MAX_AP: int = 5

# === Queue config ===
@onready var vanguard: Array = $"../Actors/Vanguard".get_children()
@onready var flank: Array = $"../Actors/Flank".get_children()

# === Systems config ===
@onready var render_system: RenderSystem = %UI

# === Lists ===
var queue: Array[Actor]
var combatants: Dictionary = {}
var portraits: Dictionary = {}

func initiate_turn(actor: Array[Actor]) -> void:
	actor[0].active = true

func _ready() -> void:
	queue = render_system.build_queue(vanguard, flank)
	portraits = render_system.display_queue(queue, portraits)
	for actor in queue: # Populate combatants dictionary
		combatants[actor.data.name] = actor

	initiate_turn(queue)

func _process(delta: float) -> void:
	for combatant in combatants:
		if combatants[combatant].target:
			render_system.display_target(combatants[combatant])
			print(combatant)
			pass
