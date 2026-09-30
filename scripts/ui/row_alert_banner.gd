extends Button


func _ready() -> void:
	custom_minimum_size = Vector2(0, 88)
	focus_mode = Control.FOCUS_NONE
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	pressed.connect(_on_pressed)
	var palette := Palette.current()
	var box := StyleBoxFlat.new()
	box.bg_color = palette["ink"]
	box.set_corner_radius_all(14)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	for state in ["normal", "hover", "pressed", "focus"]:
		add_theme_stylebox_override(state, box)
	add_theme_color_override("font_color", palette["bg"])
	add_theme_font_size_override("font_size", 20)


func show_text(message: String) -> void:
	text = "%s\nGot it" % message


func _on_pressed() -> void:
	queue_free()
