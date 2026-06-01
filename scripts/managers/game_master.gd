class_name GameMaster 
extends Node

# === GLOBALS ===
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)

# === States ===
enum State {
	IDLE,
	MOVEMENT,
	ATTACK,
	ABILITY
}

# === Mangers ===
@onready var display_manager: DisplayManager = %UI
@onready var grid_manager: GridManager = %GridMap
@onready var turn_manager: TurnManager = %Actors

func _ready() -> void:
	var flank = turn_manager.get_child(0).get_children()
	var vanguard = turn_manager.get_child(1).get_children()
	Manifest.queue.append_array(vanguard)
	Manifest.queue.append_array(flank)
	Manifest.add_combatants(Manifest.queue)
	
	for combatant in Manifest.combatants:
		grid_manager.toggle_obstacle(Vector2i(combatant.position / CELL_SIZE), true)
	
	turn_manager.roll_for_init(Manifest.queue)
	display_manager.log_init()
	display_manager.display_queue(Manifest.queue)
	turn_manager.initiate_turn(Manifest.queue)

func _process(delta: float) -> void:
	for combatant in Manifest.combatants:
		if combatant.target:
			display_manager.display_target(combatant)

# === Move Actor ===
var current_state: State = State.IDLE
func _on_grid_map_cell_pressed(coords: Vector2i) -> void:
	match current_state:
		State.IDLE:
			print('No action selected')
		
		State.MOVEMENT:
			# setup
			var active_actor = Manifest.queue[0]
			var start_pos = Vector2i(active_actor.position / CELL_SIZE)
			var path = grid_manager.find_path(start_pos, coords)
			var spd = active_actor.data.spd
			
			# exit if out of range 
			if (path.size() - 1) > spd: return print("Too far...") 
			
			# move actor
			for cell in path:
				var target = Vector2(cell * 64)
				var tween = create_tween()
				tween.tween_property(active_actor, "position", target, 0.2) # move along path
				await tween.finished
			grid_manager.toggle_obstacle(coords, true) # set new position as unwalkable
			grid_manager.clear_highlights()
			current_state = State.IDLE
		
		_:
			print("[I AM ERROR] Unknown state")

# === Utils ===
func toggle_movement_mode() -> void:
	if current_state == State.MOVEMENT:
		current_state = State.IDLE
	else:
		current_state = State.MOVEMENT
