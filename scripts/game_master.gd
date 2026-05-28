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
var portraits: Dictionary = {}

# === Queue ===
func build_queue(actors: Array[Actor]) -> void:
	# Configure queue
	actors.append_array(vanguard)
	actors.append_array(flank)
	actors.sort_custom(func(a, b): return a.data.spd > b.data.spd)

	# Clear queue display
	for portrait in queue_display.get_children():
		portrait.queue_free()

	# Fill active display
	var portrait = portrait_scene.instantiate()
	active_display.add_child(portrait)
	portrait.link(actors[0].data)
	actors.pop_front() # remove active actor

	# Fill queue display
	actors.reverse()
	for actor in actors:
		portrait = portrait_scene.instantiate()
		queue_display.add_child(portrait)
		portrait.link(actor.data)



func _ready() -> void:
	build_queue(queue)
