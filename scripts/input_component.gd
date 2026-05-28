class_name InputComponent
extends Node

# Configs
var move_dir: Vector2 = Vector2.ZERO
var selected: bool = false
@onready var anim_player: AnimationPlayer = $"../AnimPlayer"
@export var actor: Actor


# Map input
func update() -> void:
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	selected = Input.is_action_just_pressed("select")

# Mouse
func _on_actor_mouse_entered() -> void:
	anim_player.play("active")
	actor.target = true
	
func _on_actor_mouse_exited() -> void:
	anim_player.play("idle")
	actor.target = false
