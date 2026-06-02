class_name GameMaster 
extends Node

# === GLOBALS ===
const GRID_SIZE: Vector2i = Vector2(12, 5)
const CELL_SIZE: Vector2i = Vector2(64, 64)

# === States ===
enum State {
	IDLE,
	MOVE,
	ATTACK,
	ABILITY
}
var current_state: State = State.IDLE

# === Systems ===
@onready var combat_system: CombatSystem = %Actors
@onready var render_system: RenderSystem = %UI
@onready var grid_map: Grid = %GridMap

# === On Startup ===
func _ready() -> void:
	var flank = combat_system.get_child(0).get_children()
	var vanguard = combat_system.get_child(1).get_children()
	Manifest.queue.append_array(vanguard)
	Manifest.queue.append_array(flank)
	Manifest.add_combatants(Manifest.queue)
	
	for combatant in Manifest.combatants: grid_map.toggle_obstacle(Vector2i(combatant.position) / CELL_SIZE, true)
	
	combat_system.roll_init(Manifest.queue)
	render_system.log_init()
	render_system.display_queue(Manifest.queue)
	combat_system.initiate_turn(Manifest.queue)

# === Per Frame ===
func _process(delta: float) -> void:
	for combatant in Manifest.combatants:
		if combatant.target: render_system.display_target(combatant)

# === When User Selects a Cell ===
func _on_grid_map_cell_pressed(coords: Vector2i) -> void:
	match current_state:
		State.IDLE: print('No action selected')
		
		State.MOVE:
			# setup
			var active_actor = Manifest.queue[0]
			var start_pos = Vector2i(active_actor.position) / CELL_SIZE
			var spd = active_actor.data.spd
			
			# get path
			grid_map.toggle_obstacle(start_pos, false) # set starting pos as walkable
			var path = grid_map.find_path(start_pos, coords)
			
			# exit if out of range 
			if (path.size() - 1) > spd:
				grid_map.toggle_obstacle(start_pos, false)
				return print("Too far...")
			
			# move actor
			for cell in path:
				var target = Vector2(cell * 64)
				var tween = create_tween()
				tween.tween_property(active_actor, "position", target, 0.2) # move along path
				await tween.finished
			grid_map.toggle_obstacle(coords, true) # set new position as unwalkable
			toggle_state(State.IDLE)
		
		State.ATTACK:
			var attacker = Manifest.queue[0]
			var target = Manifest.gridmap.get(coords)
			if target: 
				var results = combat_system.roll_attack(attacker, target)
				print(results) 
			
			
			
			
			else: print("No target...")
			
			
			
			
		_: print("[I AM ERROR] Unknown state")

# === Utils ===
func toggle_state(target_state: State) -> void:
	if current_state == target_state: current_state = State.IDLE
	else: current_state = target_state
	
	print("State changed to: ", State.keys()[current_state])
	
	match current_state:
		State.IDLE:
			grid_map.clear_highlights()
		State.MOVE:
			grid_map.clear_highlights()
			render_system.highlight_range(Manifest.queue[0], current_state)
		State.ATTACK:
			grid_map.clear_highlights()
			render_system.highlight_range(Manifest.queue[0], current_state)
