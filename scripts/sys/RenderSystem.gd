@tool
class_name RenderSystem
extends Control

# === Config ===
@onready var portrait_scene: PackedScene = preload("uid://sv3c1o1hl810")
@onready var queue_display: Container = %QueueBox
@onready var active_display: Container = %ActiveBox
@onready var target_display: Container = %TargetBox
@onready var combat_log: RichTextLabel = %CombatLog
@onready var game_master: GameMaster = $".."
@onready var grid_map: Grid = %GridMap
@onready var combat_system: CombatSystem = %Actors

# === Display Queue Info ===
func display_queue(queue: Array[Actor]) -> void:
	var copy_of_queue = queue.duplicate() # use copy for function

	# Clear and fill active display
	for child in active_display.get_node("HBoxContainer/ActiveActorPortrait").get_children():
		child.queue_free()
	var portrait = portrait_scene.instantiate()
	portrait.actor_name = copy_of_queue[0].data.name # link actor to portrait
	portrait.texture = copy_of_queue[0].data.faceset # populate portrait w/texture
	
	# display portrait and stats
	var active_actor = copy_of_queue[0]
	active_display.get_node("HBoxContainer/ActiveActorPortrait").add_child(portrait)
	active_display.get_node("name").text = active_actor.data.name
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/hp").text = "HP: " + str(Manifest.combatants[active_actor]["HP"])
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/ap").text = "AP: " + str(Manifest.combatants[active_actor]["AP"])
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/pwr").text = "PWR: " + str(active_actor.data.pwr)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/def").text = "DEF: " + str(active_actor.data.def)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/dex").text = "DEX: " + str(active_actor.data.dex)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/spd").text = "SPD: " + str(active_actor.data.spd)
	
	# add to dictionary
	Manifest.add_portrait(copy_of_queue[0], portrait)
	copy_of_queue.pop_front() # remove active actor

	# Clear and fill queue display, and populate portraits dictionary
	for child in queue_display.get_children():
		child.queue_free()
	copy_of_queue.reverse() # descending order for scrollbox
	for actor in copy_of_queue:
		portrait = portrait_scene.instantiate()
		portrait.actor_name = actor.data.name
		portrait.texture = actor.data.faceset
		queue_display.add_child(portrait)
		Manifest.add_portrait(actor, portrait)

# === Display Target Info ===
func display_target(target: Actor) -> void:
	var portrait = portrait_scene.instantiate()
	for child in target_display.get_node("HBoxContainer/TargetActorPortrait").get_children():
		child.queue_free()
	target_display.get_node("HBoxContainer/TargetActorPortrait").add_child(portrait)
	portrait.actor_name = target.data.name # link actor to portrait
	portrait.texture = target.data.faceset # populate portrait w/texture
	target_display.get_node("name").text = target.data.name
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/hp").text = str(Manifest.combatants[target]["HP"]) + " :HP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/ap").text = str(Manifest.combatants[target]["AP"]) + " :AP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/pwr").text = str(target.data.pwr) + " :PWR" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/def").text = str(target.data.def) + " :DEF" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/dex").text = str(target.data.dex) + " :DEX" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/spd").text = str(target.data.spd) + " :SPD" 

# === Diplay Init Rolls ===
func log_init() -> void:
	for combatant in Manifest.combatants:
		combat_log.append_text("[[color=darkgreen]INITIATIVE[/color]] " + combatant.data.name + " rolled a " + str(Manifest.combatants[combatant]["init"]) + "![br]")

# === Toggle Move State ===
func _on_move_button_pressed() -> void:
	game_master.toggle_state(GameMaster.State.MOVE)

# === Toggle Attack State ===
func _on_attack_button_pressed() -> void:
	game_master.toggle_state(GameMaster.State.ATTACK)
	
# === Calculate range ===
var in_range = []
func highlight_range(actor: Actor, state: GameMaster.State) -> void:
	match state:
		GameMaster.State.MOVE: 
			in_range.clear()
			in_range = combat_system.get_cells_in_range(actor)
			grid_map.highlight_cells(in_range, state)
		
		GameMaster.State.ATTACK:
			in_range.clear()
			in_range = combat_system.get_targets_in_range(actor)
			grid_map.highlight_cells(in_range, state)
