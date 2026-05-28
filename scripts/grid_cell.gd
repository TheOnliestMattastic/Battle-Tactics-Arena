extends PanelContainer

var style_default: StyleBoxFlat
var style_hover: StyleBoxFlat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	style_default = self.get_theme_stylebox("panel").duplicate()
	style_hover = style_default.duplicate()
	style_hover.bg_color = Color(0.7, 0.7, 0.7, 0.7)

func _on_mouse_entered() -> void:
	self.add_theme_stylebox_override("panel", style_hover)


func _on_mouse_exited() -> void:
	self.add_theme_stylebox_override("panel", style_default)
