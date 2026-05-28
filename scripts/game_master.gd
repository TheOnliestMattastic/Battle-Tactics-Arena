class_name GameMaster 
extends Node

# GLOBALS
const MAP_SIZE: Vector2i = Vector2i(768, 320)
const GRID_SIZE: Vector2i = Vector2i(12, 5)
const CELL_SIZE: Vector2i = Vector2i(64, 64)
const MAX_AP: int = 5

# Queue config
@export var portrait_scene: PackedScene = preload("uid://sv3c1o1hl810")
@export var queue_display: Container
@export var active_display: Container
@export var target_display: Container
@onready var vanguard: Array = $"../Actors/Vanguard".get_children()
@onready var flank: Array = $"../Actors/Flank".get_children()
var queue: Array[Actor] = []
var combatants: Dictionary = {}
var portraits: Dictionary = {}

# === Queue ===
func build_queue(actors: Array[Actor]) -> void:
	# Configure queue
	actors.append_array(vanguard)
	actors.append_array(flank)
	actors.sort_custom(func(a, b): return a.data.spd > b.data.spd)
	var copy_of_queue = actors.duplicate()
	
	# Populate combatants dictionary
	for actor in actors:
		combatants[actor.data.name] = actor

	# Clear and fill active display
	for child in active_display.get_children():
		child.queue_free()
	var portrait = portrait_scene.instantiate()
	portrait.actor_name = copy_of_queue[0].data.name # link actor to portrait
	portrait.texture = copy_of_queue[0].data.faceset # populate portrait w/texture
	active_display.add_child(portrait) # add portrait to display 
	portraits[copy_of_queue[0].data.name] = portrait # add to dictionary
	copy_of_queue.pop_front() # remove active actor

	# Clear and fill queue display
	for child in queue_display.get_children():
		child.queue_free()
	copy_of_queue.reverse() # descending order for scrollbox
	for actor in copy_of_queue:
		portrait = portrait_scene.instantiate()
		portrait.actor_name = actor.data.name
		portrait.texture = actor.data.faceset
		queue_display.add_child(portrait)
		portraits[actor.data.name] = portrait

func initiate_turn(actors: Array[Actor]) -> void:
	queue[0].active = true

func _ready() -> void:
	build_queue(queue)
	initiate_turn(queue)
