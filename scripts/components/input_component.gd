class_name InputComponent
extends Node

# Configs
@onready var anim_player: AnimationPlayer = $"../AnimPlayer"
@export var actor: Actor

# Mouse
func _on_actor_mouse_entered() -> void:
	anim_player.play("active")
	actor.target = true
	
func _on_actor_mouse_exited() -> void:
	anim_player.play("idle")
	actor.target = false
