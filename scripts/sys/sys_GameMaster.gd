class_name GameMaster 
extends Node

# === GLOBALS ===
const GRID_SIZE: Vector2i = Vector2i(12, 5)
const CELL_SIZE: Vector2i = Vector2i(64, 64)

# === States ===
enum State {
	IDLE,
	MOVE,
	ATTACK,
	ABILITY
}
var current_state: State

# === Systems ===
@onready var combat_manager: CombatManager = %Actors
@onready var display_manager: DisplayManager = %UI
@onready var grid_map: Grid = %GridMap

# === On Startup ===
func _ready() -> void:
	var combatants = get_combatants()
	Manifest.queue.append_array(combatants)
	Manifest.add_combatants(Manifest.queue)
	
	for combatant in Manifest.combatants: grid_map.toggle_obstacle(Vector2i(combatant.position) / CELL_SIZE, true)
	
	CombatManager.roll_for_init(Manifest.queue)
	display_manager.log_init()
	toggle_state(State.IDLE)

# === Per Frame ===
func _process(delta: float) -> void:
	display_manager.display_queue(Manifest.queue)
	for combatant in Manifest.combatants:
		if combatant.target: display_manager.display_target(combatant)

# === When User Selects a Cell ===
func _on_grid_map_cell_pressed(coords: Vector2i) -> void:
	match current_state:
		State.IDLE: 
			display_manager.log_to_banner('No action selected')
		
		State.MOVE:
			# setup
			var mover = Manifest.queue[0]
			var start_pos = Vector2i(mover.position) / CELL_SIZE
			var spd = mover.data.spd
			
			# get path
			grid_map.toggle_obstacle(start_pos, false) # set starting pos as walkable
			var path = grid_map.find_path(start_pos, coords)
			
			# exit if out of range 
			if (path.size() - 1) > spd:
				grid_map.toggle_obstacle(start_pos, false)
				return display_manager.log_to_banner("Too far...")
			
			# move actor
			for cell in path:
				var target = Vector2(cell * 64)
				var tween = create_tween()
				tween.tween_property(mover, "position", target, 0.2) # move along path
				await tween.finished
			grid_map.toggle_obstacle(coords, true) # set new position as unwalkable
			Manifest.gridmap.get(coords).occupant = mover
			Manifest.gridmap.get(start_pos).occupant = null
			toggle_state(State.IDLE)
		
		State.ATTACK:
			var attacker = Manifest.queue[0]
			var target = Manifest.gridmap.get(coords).occupant
			if not target: return display_manager.log_to_banner("No target...")
			
			# TESTING: AP mechanics; need to move later
			if not CombatManager.has_enough_ap(attacker): return display_manager.log_to_banner("Not enough AP...")
			CombatManager.spend_ap(attacker)
			
			# calculate hit and log
			var results = CombatManager.roll_for_attack(attacker, target)
			display_manager.log_hit_results(results)
			if not results.get("success"): return toggle_state(current_state)
			
			# calculate damage and log
			var damage = CombatManager.roll_for_damage(attacker, target)
			display_manager.log_damage_results(damage)
			combat_manager.apply_damage(damage)
			toggle_state(State.IDLE)
		
		State.ABILITY:
			var caster = Manifest.queue[0]
			var result = caster.data.abilities[0].execute(caster, coords)
			if not result["success"]: return display_manager.log_to_banner(result["message"])
			print(result)
		
		_: print("[I AM ERROR] Unknown state")

# === Utils ===
func toggle_state(target_state: State) -> void:
	if current_state == target_state: current_state = State.IDLE
	else: current_state = target_state
	
	match current_state:
		State.IDLE:
			var active = Manifest.queue[0].data.name
			grid_map.clear_highlights()
			display_manager.log_to_banner(active + "'s turn.")
		State.MOVE:
			grid_map.clear_highlights()
			display_manager.highlight_range(Manifest.queue[0], current_state)
			display_manager.log_to_banner("Moving...")
		State.ATTACK:
			grid_map.clear_highlights()
			display_manager.highlight_range(Manifest.queue[0], current_state)
			display_manager.log_to_banner("Attacking...")
		State.ABILITY:
			grid_map.clear_highlights()
			display_manager.log_to_banner("Choosing ability")

func actor_defeated(actor: Actor) -> void:
	var coords := Vector2i(actor.position) / CELL_SIZE
	display_manager.remove_portrait(actor)
	Manifest.remove_from_queue(actor)
	actor.queue_free()
	grid_map.toggle_obstacle(coords, false)

func end_turn() -> void:
	Manifest.queue.pop_front()
	if Manifest.queue.size() == 0:
		var combatants = get_combatants()
		Manifest.queue.clear()
		Manifest.queue.append_array(combatants)
		CombatManager.roll_for_init(Manifest.queue)
		display_manager.log_init()
	display_manager.display_queue(Manifest.queue)
	toggle_state(State.IDLE)

func get_combatants() -> Array:
	var combatants: Array
	var a = combat_manager.get_child(0).get_children()
	var b = combat_manager.get_child(1).get_children()
	combatants.append_array(a)
	combatants.append_array(b)
	return combatants

func delay_turn() -> void:
	if Manifest.queue[0].delayed: 
		display_manager.log_to_banner("Turn already delayed this turn.")
	else:
		Manifest.queue[0].delayed = true
		Manifest.queue.push_back(Manifest.queue.pop_front())
		toggle_state(State.IDLE)


func _on_skills_button_pressed() -> void:
	if not Manifest.queue[0].data.name == "Vale the Vague": return
	toggle_state(State.ABILITY)
