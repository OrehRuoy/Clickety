class_name SafeArea
extends MarginContainer

func _ready() -> void:
	get_viewport().size_changed.connect(_apply_insets)
	_apply_insets()


func _apply_insets() -> void:
	var left := 0
	var top := 0
	var right := 0
	var bottom := 0
	if OS.get_name() == "iOS":
		var win := Vector2(DisplayServer.window_get_size())
		if win.x > 0.0 and win.y > 0.0:
			var safe := DisplayServer.get_display_safe_area()
			var visible := get_viewport().get_visible_rect().size
			var scale := visible / win
			left = int(round(safe.position.x * scale.x))
			top = int(round(safe.position.y * scale.y))
			right = int(round((win.x - safe.end.x) * scale.x))
			bottom = int(round((win.y - safe.end.y) * scale.y))
	add_theme_constant_override("margin_left", maxi(0, left))
	add_theme_constant_override("margin_top", maxi(0, top))
	add_theme_constant_override("margin_right", maxi(0, right))
	add_theme_constant_override("margin_bottom", maxi(0, bottom))
