class_name ActorData
extends Resource

@export_group("ID")
@export var name: String = "Hero"
@export var spritesheet: Texture2D
@export var faceset: Texture2D

@export_group("Stats")
@export var max_hp: int = 15
@export var pwr: int = 5
@export var def: int = 5
@export var dex: int = 5
@export var spd: int = 2
