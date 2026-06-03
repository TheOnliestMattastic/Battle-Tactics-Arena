@tool
class_name Cell
extends BaseButton

@onready var texture_display: TextureRect = $TextureRect
const SIZE: Vector2i = Vector2i(32, 32)
signal cell_pressed(coords: Vector2i) # signal for GridContainer (parent node)

func _on_pressed() -> void: 
	cell_pressed.emit(Vector2i(self.position) / SIZE) # send local coords

func set_tile(sheet: Texture2D, tile_size: Vector2i, coords: Vector2i):
	var atlas = AtlasTexture.new()
	atlas.atlas = sheet
	# Define which 32x32 area to show
	atlas.region = Rect2(coords.x * tile_size.x, coords.y * tile_size.y, tile_size.x, tile_size.y)
	texture_display.texture = atlas
