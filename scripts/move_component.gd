class_name MoveComponent 
extends Node

# Configs
@export var actor: Actor
@export var sprite: Node2D
@onready var input_delay: Timer = $InputDelay
var direction: Vector2i = Vector2i.ZERO

func tick(delta: float) -> void:
	# null check
	if not actor or not input_delay.is_stopped():
		return

	# Move actor
	actor.move_and_collide(direction * GameMaster.CELL_SIZE)
	input_delay.start()
