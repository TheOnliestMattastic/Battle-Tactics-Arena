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

func _ready() -> void:
	Manifest.queue.append_array(vanguard)
	Manifest.queue.append_array(flank)
	Manifest.add_combatants(Manifest.queue)
	TurnManager.roll_for_init(Manifest.queue)
	display_manager.log_init()
	display_manager.display_queue(Manifest.queue)
	TurnManager.initiate_turn(Manifest.queue)

func _process(delta: float) -> void:
	for combatant in Manifest.combatants:
		if combatant.target:
			display_manager.display_target(combatant)
