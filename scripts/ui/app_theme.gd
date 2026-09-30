class_name AppTheme
extends Object


static func edge(palette: Dictionary) -> Color:
	var contrast := AppSettings.resolved_theme() == "contrast"
	var color: Color = palette["ink"] if contrast else palette["muted"]
	if not contrast:
		color.a = 0.28
	return color


static func card(palette: Dictionary, radius: int = 14) -> StyleBoxFlat:
	var contrast := AppSettings.resolved_theme() == "contrast"
	var box := StyleBoxFlat.new()
	box.bg_color = palette["surface"]
	box.set_corner_radius_all(radius)
	box.border_color = edge(palette)
	box.set_border_width_all(2 if contrast else 1)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box


static func apply(theme: Theme, palette: Dictionary) -> void:
	var ink: Color = palette["ink"]
	var muted: Color = palette["muted"]
	var accent: Color = palette["accent"]
	var field := card(palette, 12)
	field.content_margin_top = 10
	field.content_margin_bottom = 10
	var focus := card(palette, 12)
	focus.content_margin_top = 10
	focus.content_margin_bottom = 10
	focus.border_color = accent
	focus.set_border_width_all(2)
	var placeholder := muted
	placeholder.a = 0.75
	var selection := accent
	selection.a = 0.35
	for kind in ["LineEdit", "TextEdit"]:
		theme.set_stylebox("normal", kind, field)
		theme.set_stylebox("read_only", kind, field)
		theme.set_stylebox("focus", kind, focus)
		theme.set_color("font_color", kind, ink)
		theme.set_color("font_placeholder_color", kind, placeholder)
		theme.set_color("font_selected_color", kind, ink)
		theme.set_color("caret_color", kind, accent)
		theme.set_color("selection_color", kind, selection)
		theme.set_constant("caret_width", kind, 2)
	var picker := card(palette, 14)
	var picker_hover := card(palette, 14)
	picker_hover.border_color = accent
	for state in ["normal", "pressed", "disabled", "focus"]:
		theme.set_stylebox(state, "OptionButton", picker)
	theme.set_stylebox("hover", "OptionButton", picker_hover)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		theme.set_color(color_name, "OptionButton", ink)
	theme.set_color("font_disabled_color", "OptionButton", muted)
	theme.set_icon("arrow", "OptionButton", _chevron(ink))
	theme.set_constant("arrow_margin", "OptionButton", 12)
	var panel := card(palette, 14)
	panel.content_margin_left = 8
	panel.content_margin_right = 8
	panel.content_margin_top = 8
	panel.content_margin_bottom = 8
	var hover := StyleBoxFlat.new()
	hover.bg_color = selection
	hover.set_corner_radius_all(10)
	for state in ["hover", "selected"]:
		theme.set_stylebox(state, "PopupMenu", hover)
	theme.set_stylebox("panel", "PopupMenu", panel)
	for color_name in ["font_color", "font_hover_color", "font_accelerator_color"]:
		theme.set_color(color_name, "PopupMenu", ink)
	theme.set_constant("v_separation", "PopupMenu", 16)
	theme.set_constant("item_start_padding", "PopupMenu", 10)
	theme.set_constant("item_end_padding", "PopupMenu", 10)
	var grab := StyleBoxFlat.new()
	grab.bg_color = accent
	grab.set_corner_radius_all(6)
	var track := StyleBoxFlat.new()
	var track_color := muted
	track_color.a = 0.28
	track.bg_color = track_color
	track.set_corner_radius_all(6)
	track.content_margin_left = 4
	track.content_margin_right = 4
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	for bar in ["VScrollBar", "HScrollBar"]:
		for style_name in ["grabber", "grabber_highlight", "grabber_pressed"]:
			theme.set_stylebox(style_name, bar, grab)
		for style_name in ["scroll", "scroll_focus"]:
			theme.set_stylebox(style_name, bar, track)


static func on_node_added(node: Node) -> void:
	if node is BaseButton:
		TouchScroll.adopt(node as BaseButton)
	if node is CheckButton:
		var check := node as CheckButton
		if check.has_meta("themed"):
			return
		check.set_meta("themed", true)
		SwitchGlyph.attach(check)
		paint_card(check, 76)
		return
	if node is OptionButton:
		return
	if node is Button:
		var button := node as Button
		if button.flat:
			if button.name == "Back":
				Palette.paint_back(button)
			return
		if button.has_theme_stylebox_override("normal"):
			return
		paint_card(button, 16)


static func paint_card(button: Button, right_margin: int) -> void:
	var palette := Palette.current()
	var normal := card(palette)
	normal.content_margin_right = right_margin
	var pressed := card(palette)
	pressed.content_margin_right = right_margin
	pressed.bg_color = palette["accent"]
	pressed.bg_color.a = 0.16
	pressed.border_color = palette["accent"]
	var off := card(palette)
	off.content_margin_right = right_margin
	off.bg_color.a = 0.55
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", off)


static func _chevron(color: Color) -> Texture2D:
	var image := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for step in 9:
		for thick in 3:
			var y := 9 + step + thick
			image.set_pixel(14 - step, mini(y, 27), color)
			image.set_pixel(14 + step, mini(y, 27), color)
	return ImageTexture.create_from_image(image)
