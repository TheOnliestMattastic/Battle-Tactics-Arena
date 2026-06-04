@tool
class_name Actor
extends Area2D

# Configs
@export var data: ActorData
@onready var anim: AnimationPlayer = $AnimPlayer
@onready var sprite: Sprite2D = $Sprite
var target: bool = false

# Components
@onready var input_component: InputComponent = $InputComponent

func _ready() -> void:
	# null check
	if not data:
		return

	# update spritesheet
	if data.spritesheet:
		sprite.set_texture(data.spritesheet)
