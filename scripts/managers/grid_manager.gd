@tool
class_name GridManager
extends Node

@export var tilesheet: Texture2D = preload("uid://bt77eidvhb0ii")
@export var cell_scene: PackedScene = preload("uid://oc0dkklawq5y")
var grid_size: Vector2i = GameMaster.GRID_SIZE
var cell_size: Vector2i = GameMaster.CELL_SIZE
var astar := AStarGrid2D.new()
var grid: Dictionary = {}

func _init():
	astar.region = Rect2i(Vector2i.ZERO, grid_size)
	astar.cell_size = cell_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func _ready() -> void:
	var cells = self.get_children()
	for i in range(cells.size()):
		var cell = cells[i]
		cell.cell_pressed.connect(_on_cell_pressed) # Connect to cell signals
		randomize_tile(cell)
		
		# calculate cell coords and add them to the dictionary
		var x = i % grid_size.x
		var y = i / grid_size.x
		var coords = Vector2i(x,y)
		grid[coords] = cell

# === Pass Cell Signal to GameMaster ===
signal cell_pressed(coords: Vector2)
func _on_cell_pressed(coords: Vector2):
	cell_pressed.emit(coords)

# === Highlight Movement Range ===
func _on_ui_move_mode(tiles: Dictionary) -> void:
	for walkable in tiles:
		if tiles[walkable] == true:
			grid[walkable].modulate = Color(0.0, 1.0, 0.0, 1.0)

# === Utils ===
# Select Random Tile from Tilesheet
func randomize_tile(tile):
	var tile_size = Cell.SIZE
	var sheet_cols = tilesheet.get_width() / tile_size.x
	var sheet_rows = tilesheet.get_height() / tile_size.y
	var random_x = randi() % int(sheet_cols)
	var random_y = randi() % int(sheet_rows)
	var random_tile_coords = Vector2i(random_x, random_y)
	if tile.has_method("set_tile"):
		tile.set_tile(tilesheet, tile_size, random_tile_coords)

# Mark cell as unwalkable
func toggle_obstacle(coords: Vector2, is_solid: bool):
	astar.set_point_solid(coords, is_solid)

# Pathfinding
func find_path(start: Vector2, end: Vector2) -> Array:
	return astar.get_id_path(start, end)

# Clear highlights
func clear_highlights() -> void:
	for cell in grid:
		grid[cell].modulate = Color(1, 1, 1, 1)
