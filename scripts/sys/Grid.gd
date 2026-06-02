@tool
class_name Grid
extends Node

@export var tilesheet: Texture2D = preload("uid://bt77eidvhb0ii")
@export var cell_scene: PackedScene = preload("uid://oc0dkklawq5y")
var astar := AStarGrid2D.new()
var gridmap: Dictionary = {}

func _init():
	astar.region = Rect2i(Vector2i.ZERO, GameMaster.GRID_SIZE)
	astar.cell_size = GameMaster.CELL_SIZE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func _ready() -> void:
	var cells = self.get_children()
	for i in range(cells.size()):
		var cell = cells[i]
		cell.cell_pressed.connect(_on_cell_pressed) # Connect to cell signals
		randomize_tile(cell)
		
		# calculate cell coords and add them to the dictionary
		var x = i % GameMaster.GRID_SIZE.x
		var y = i / GameMaster.GRID_SIZE.x
		var coords = Vector2i(x,y)
		gridmap[coords] = cell

# === Pass Cell Signal to GameMaster ===
signal cell_pressed(coords: Vector2)
func _on_cell_pressed(coords: Vector2):
	cell_pressed.emit(coords)

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
	for cell in gridmap:
		gridmap[cell].modulate = Color(1, 1, 1, 1)

# Movement range
func highlight_cells(cells: Array, state: GameMaster.State) -> void:
	var color: Color
	match state:
		GameMaster.State.MOVE: color = Color(0.0, 1.0, 0.0, 1.0)
		GameMaster.State.ATTACK: color = Color(1.0, 0.0, 0.0, 1.0)
	for cell in cells:
		gridmap[cell].modulate = color
