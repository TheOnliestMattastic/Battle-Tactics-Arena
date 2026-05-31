class_name GameMaster 
extends Node

# === GLOBALS ===
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)

# === States ===
var is_moving: bool = false
var is_attacking: bool = false

# === Queue config ===
@onready var vanguard: Array = %Vanguard.get_children()
@onready var flank: Array = %Flank.get_children()

# === Systems config ===
@onready var display_manager: DisplayManager = %UI
@onready var grid_map: GridData = %GridMap

func _ready() -> void:
	Manifest.queue.append_array(vanguard)
	Manifest.queue.append_array(flank)
	Manifest.add_combatants(Manifest.queue)
	
	for combatant in Manifest.combatants:
		grid_map.toggle_obstacle(Vector2i(combatant.position / CELL_SIZE), true)
	
	TurnManager.roll_for_init(Manifest.queue)
	display_manager.log_init()
	display_manager.display_queue(Manifest.queue)
	TurnManager.initiate_turn(Manifest.queue)

func _process(delta: float) -> void:
	for combatant in Manifest.combatants:
		if combatant.target:
			display_manager.display_target(combatant)

func _on_grid_map_grid_pressed(coords: Vector2i) -> void:
	# Exit if not in moving mode
	if is_moving:
		# store active actor's data
		var actor = Manifest.queue[0]
		var start = Vector2i(actor.position / CELL_SIZE)
		
		# set starting pos as walkable
		grid_map.toggle_obstacle(start, false) 
		var path = grid_map.find_path(start, coords)
		for cell in path:
			var target = Vector2(cell * 64)
			var tween = create_tween()
			tween.tween_property(actor, "position", target, 0.2)
			await tween.finished
		grid_map.toggle_obstacle(coords, true) # set new position as unwalkable
