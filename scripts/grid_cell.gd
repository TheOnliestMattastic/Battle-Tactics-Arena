class_name GridCell
extends BaseButton

# Send signal to GridContainer (parent node)
signal cell_pressed(coords: Vector2i)
const CELL_SIZE: Vector2 = Vector2(32, 32)

func _on_pressed() -> void: 
	cell_pressed.emit(Vector2i(self.position / CELL_SIZE)) # send local coords
