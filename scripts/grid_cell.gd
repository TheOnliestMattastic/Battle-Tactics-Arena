extends PanelContainer

var styleDefault: StyleBoxFlat
var styleHover: StyleBoxFlat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	styleDefault = self.get_theme_stylebox("panel").duplicate()
	styleHover = styleDefault.duplicate()
	styleHover.bg_color = Color(0.7, 0.7, 0.7, 0.7)

func _on_mouse_entered() -> void:
	self.add_theme_stylebox_override("panel", styleHover)


func _on_mouse_exited() -> void:
	self.add_theme_stylebox_override("panel", styleDefault)
