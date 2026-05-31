class_name MoveComponent 
extends Node

# Configs
@export var actor: Actor
@export var sprite: Node2D
@onready var input_delay: Timer = $InputDelay
var direction: Vector2 = Vector2.ZERO
@onready var anim_player: AnimationPlayer = $"../AnimPlayer"

func tick(delta: float) -> void:
	# null check
	if not actor or not input_delay.is_stopped():
		return

	# Move actor
	actor.position = actor.position + direction * Vector2(64, 64)
	input_delay.start()
