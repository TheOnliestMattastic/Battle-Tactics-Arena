class_name Actor
extends CharacterBody2D

# Configs
@export var data: ActorData
@onready var anim: AnimationPlayer = $AnimPlayer
@onready var sprite: Sprite2D = $Sprite
var active: bool = false

# Components
@onready var input_component: InputComponent = %InputComponent
@onready var ap_component: APComponent = %APComponent
@onready var move_component: MoveComponent = %MoveComponent

func _ready() -> void:
	# null check
	if not data:
		return

	# update spritesheet
	if data.spritesheet:
		sprite.set_texture(data.spritesheet)

func _process(delta: float) -> void:
	# Update components
	input_component.update()
	
	if not active:
		return
	else:
		move_component.direction = input_component.move_dir
		move_component.tick(delta)

		# DEBUGGER spend ap 
		if input_component.selected:
			ap_component.spend_ap(1)
