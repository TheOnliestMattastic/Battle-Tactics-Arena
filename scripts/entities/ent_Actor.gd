class_name Actor
extends Area2D

# Configs
@export var data: ActorData
@onready var anim: AnimationPlayer = $AnimPlayer
@onready var sprite: Sprite2D = $Sprite
var target: bool = false
var delayed: bool = false

func _ready() -> void:
	if not data: return
	if data.spritesheet: sprite.set_texture(data.spritesheet)
	if data.name: self.name = data.name

func _physics_process(delta: float) -> void:
	if not Manifest.queue: return
	if  self == Manifest.queue[0]: anim.play("active_down") 
	elif target: return
	else: anim.play("idle_down")

func _on_mouse_entered() -> void:
	if self == Manifest.queue[0]: return
	anim.play("active_down")
	target = true

func _on_mouse_exited() -> void:
	if self == Manifest.queue[0]: return
	anim.play("idle_down")
	target = false
