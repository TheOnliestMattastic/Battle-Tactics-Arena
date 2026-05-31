class_name GridData
extends Node

var grid_size: Vector2 = GameMaster.GRID_SIZE
var cell_size: Vector2 = GameMaster.CELL_SIZE
var astar := AStarGrid2D.new()

signal grid_pressed(coords: Vector2)

func _init():
	astar.region = Rect2i(Vector2i.ZERO, grid_size)
	astar.cell_size = cell_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func _ready() -> void:
	for cell in self.get_children():
		cell.cell_pressed.connect(_on_cell_pressed)

func toggle_obstacle(coords: Vector2, is_solid: bool):
	astar.set_point_solid(coords, is_solid)

func find_path(start: Vector2, end: Vector2) -> Array:
	return astar.get_id_path(start, end)

func _on_cell_pressed(coords: Vector2):
	grid_pressed.emit(coords)
