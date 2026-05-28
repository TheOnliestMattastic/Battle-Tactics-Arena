class_name MoveComponent 
extends Node

# Configs
@export var actor: Actor
@export var sprite: Node2D
@onready var input_delay: Timer = $InputDelay
var direction: Vector2 = Vector2.ZERO

func tick(delta: float) -> void:
	# null check
	if not actor or not input_delay.is_stopped():
		return

	# Move actor
	actor.position = actor.position + direction * GameMaster.CELL_SIZE
	input_delay.start()
