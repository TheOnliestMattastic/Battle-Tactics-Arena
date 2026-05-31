class_name DisplayManager
extends Control

# === Config ===
@export var portrait_scene: PackedScene = preload("uid://sv3c1o1hl810")
@export var queue_display: Container
@export var active_display: Container
@export var target_display: Container 
@export var combat_log: RichTextLabel
@onready var game_master: GameMaster = $".."

func display_queue(queue: Array[Actor]) -> void:
	var copy_of_queue = queue.duplicate() # use copy for function

	# Clear and fill active display
	for child in active_display.get_node("HBoxContainer/ActiveActorPortrait").get_children():
		child.queue_free()
	var portrait = portrait_scene.instantiate()
	portrait.actor_name = copy_of_queue[0].data.name # link actor to portrait
	portrait.texture = copy_of_queue[0].data.faceset # populate portrait w/texture
	
	# display portrait and stats
	active_display.get_node("HBoxContainer/ActiveActorPortrait").add_child(portrait)
	active_display.get_node("name").text = copy_of_queue[0].data.name
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/hp").text = "HP: " + str(copy_of_queue[0].data.hp)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/ap").text = "AP: " + str(copy_of_queue[0].data.ap)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/pwr").text = "PWR: " + str(copy_of_queue[0].data.pwr)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/def").text = "DEF: " + str(copy_of_queue[0].data.def)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/dex").text = "DEX: " + str(copy_of_queue[0].data.dex)
	active_display.get_node("HBoxContainer/ActiveActorStatMargin/ActiveActorStatBox/spd").text = "SPD: " + str(copy_of_queue[0].data.spd)
	
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

func display_target(target: Actor) -> void:
	var portrait = portrait_scene.instantiate()
	for child in target_display.get_node("HBoxContainer/TargetActorPortrait").get_children():
		child.queue_free()
	target_display.get_node("HBoxContainer/TargetActorPortrait").add_child(portrait)
	portrait.actor_name = target.data.name # link actor to portrait
	portrait.texture = target.data.faceset # populate portrait w/texture
	target_display.get_node("name").text = target.data.name
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/hp").text = str(target.data.hp) + " :HP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/ap").text = str(target.data.ap) + " :AP" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/pwr").text = str(target.data.pwr) + " :PWR" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/def").text = str(target.data.def) + " :DEF" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/dex").text = str(target.data.dex) + " :DEX" 
	target_display.get_node("HBoxContainer/TargetActorStatMargin/TargetActorStatBox/spd").text = str(target.data.spd) + " :SPD" 

func log_init() -> void:
	for combatant in Manifest.combatants:
		combat_log.append_text("[[color=darkgreen]INITIATIVE[/color]] " + combatant.data.name + " rolled a " + str(Manifest.combatants[combatant]["init"]) + "![br]")

func _on_move_button_pressed() -> void:
	# TODO: highlight movement range
	if not game_master.is_moving:
		game_master.is_moving = true
	else:
		game_master.is_moving = false
		
	print(game_master.is_moving)
