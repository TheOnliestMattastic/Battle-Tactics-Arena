class_name DisplayManager
extends Control

# === Config ===
@onready var portrait_scene: PackedScene = preload("uid://sv3c1o1hl810")
@onready var queue_display: Container = %QueueBox
@onready var active_display: Container = %ActiveBox
@onready var target_display: Container = %TargetBox
@onready var combat_log: RichTextLabel = %CombatLog
@onready var banner: Label = %Banner
@onready var game_master: GameMaster = $".."
@onready var grid_map: Grid = %GridMap
@onready var combat_manager: CombatManager = %Actors
@onready var delay_button: TextureButton = %delayButton
@onready var move_button: TextureButton = %moveButton
@onready var skills_button: TextureButton = %skillsButton
@onready var attack_button: TextureButton = %attackButton

func _process(delta: float) -> void:
	var active = Manifest.queue[0]
	if active.delayed or active.moved or active.attacked: delay_button.disabled = true
	else: delay_button.disabled = false
	
	if active.moved: move_button.disabled = true
	else: move_button.disabled = false
	
	if active.attacked: 
		attack_button.disabled = true
		skills_button.disabled = true
	else: 
		attack_button.disabled = false
		skills_button.disabled = false

# === Signals ===
func _on_move_button_pressed() -> void: # Toggle move state
	game_master.toggle_state(GameMaster.State.MOVE)

func _on_attack_button_pressed() -> void: # Toggle attack state
	game_master.toggle_state(GameMaster.State.ATTACK)

func _on_end_button_pressed() -> void:
	game_master.end_turn()

func _on_delay_button_pressed() -> void:
	game_master.delay_turn()

func _on_skills_button_pressed() -> void:
	if not Manifest.queue[0].data.abilities: return
	game_master.toggle_state(GameMaster.State.ABILITY)

# === Display Queue Info ===
func display_queue(queue: Array[Actor]) -> void:
	var copy_of_queue = queue.duplicate() # use copy for function

	# Clear and fill active display
	for child in active_display.get_node("HBoxContainer/ActiveActorPortrait").get_children(): child.queue_free()
	var portrait = portrait_scene.instantiate()

	copy_of_queue.pop_front() # remove active actor
	for child in queue_display.get_children(): child.queue_free()
	copy_of_queue.reverse() # descending order for scrollbox
	for actor in copy_of_queue:
		portrait = portrait_scene.instantiate()
		portrait.texture = actor.data.faceset
		queue_display.add_child(portrait)
		Manifest.add_portrait(actor, portrait)

# === Display Active Info ===
func display_active(actor: Actor) -> void:
	var portrait = portrait_scene.instantiate()
	portrait.texture = actor.data.faceset # populate portrait w/texture
	active_display.get_node("HBoxContainer/ActiveActorPortrait").add_child(portrait)
	active_display.get_node("name").text = actor.data.name
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/hp").text = "HP: " + str(Manifest.combatants[actor]["HP"])
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/ap").text = "AP: " + str(Manifest.combatants[actor]["AP"])
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/pwr").text = "PWR: " + str(actor.data.pwr)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/def").text = "DEF: " + str(actor.data.def)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/dex").text = "DEX: " + str(actor.data.dex)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/spd").text = "SPD: " + str(actor.data.spd)

# === Display Target Info ===
func display_target(target: Actor) -> void:
	var portrait = portrait_scene.instantiate()
	for child in target_display.get_node("HBoxContainer/TargetActorPortrait").get_children():
		child.queue_free()
	target_display.get_node("HBoxContainer/TargetActorPortrait").add_child(portrait)
	portrait.texture = target.data.faceset # populate portrait w/texture
	target_display.get_node("name").text = target.data.name
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/hp").text = str(Manifest.combatants[target]["HP"]) + " :HP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/ap").text = str(Manifest.combatants[target]["AP"]) + " :AP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/pwr").text = str(target.data.pwr) + " :PWR" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/def").text = str(target.data.def) + " :DEF" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/dex").text = str(target.data.dex) + " :DEX" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/spd").text = str(target.data.spd) + " :SPD" 

# === Display Logs ===
func log_init() -> void:
	for combatant in Manifest.combatants:
		combat_log.append_text("[[color=darkgreen]INITIATIVE[/color]] " + combatant.data.name + " rolled a [color=cyan]" + str(Manifest.combatants[combatant]["init"]) + "[/color]![br]")

func log_to_banner(message: String) -> void:
	banner.text = message

func log_hit_results(results) -> void:
	var attacker = results.get("attacker")
	var defender = results.get("defender")
	var successful = results.get("success")
	combat_log.append_text("[[color=darkred]ATTACK[/color]] [color=red]" + attacker.data.name + "[/color] rolled a [color=cyan]" + str(results.get("hit")) + "[/color]![br]")
	combat_log.append_text("[[color=darkblue]EVASION[/color]] [color=blue]" + defender.data.name + "[/color] rolled a [color=cyan]" + str(results.get("evasion")) + "[/color]![br]")
	if successful: combat_log.append_text("The [color=darkgreen]attack succeeded[/color]![br]")
	else: combat_log.append_text("The [color=red]attack failed[/color] to land. [color=blue]" + defender.data.name + "[/color] successfully evaded the attack![br]")

func log_damage_results(results) -> void:
	var attacker = results.get("attacker")
	var defender = results.get("defender")
	combat_log.append_text("[[color=darkred]DAMAGE[/color]] [color=red]" + attacker.data.name + "[/color] attacked for [color=cyan]" + str(results["raw"]) + "[/color] pts of damage! But [color=blue]" + defender.data.name + "[/color] deflected [color=cyan]" + str(results["deflected"]) + "[/color] pts for a total of [color=cyan]" + str(results["damage"]) + "[/color] incoming damage![br]")

# === Highlights ===
func highlight_range(actor: Actor, state: GameMaster.State) -> void:
	var in_range = []
	var targets = []
	match state:
		GameMaster.State.MOVE: 
			in_range = GridMath.get_cells_in_range(actor, grid_map.astar)
			targets = GridMath.get_targets_in_range(actor, 2, grid_map.astar)
			Grid.highlight_cells(in_range, "green")
			Grid.highlight_cells(targets, "red")
		
		GameMaster.State.ATTACK:
			targets = GridMath.get_targets_in_range(actor, 2, grid_map.astar)
			Grid.highlight_cells(targets, "red")

# === Display Changes ===
func remove_portrait(actor: Actor) -> void:
	var portrait = Manifest.portraits.find_key(actor)
	for child in queue_display.get_children():
		if child == portrait: 
			Manifest.portraits.erase(portrait)
			child.free()
			break
