class_name Palette
extends Object

const THEMES := {
	"warm": {
		"bg": "#FBF6EE",
		"surface": "#FFFFFF",
		"ink": "#1E1B18",
		"muted": "#5E564E",
		"accent": "#B4492E",
		"accent_ink": "#FFFFFF",
	},
	"night": {
		"bg": "#161412",
		"surface": "#221F1C",
		"ink": "#F3ECE2",
		"muted": "#B8AEA2",
		"accent": "#E58A6B",
		"accent_ink": "#161412",
	},
	"contrast": {
		"bg": "#000000",
		"surface": "#000000",
		"ink": "#FFFFFF",
		"muted": "#FFFFFF",
		"accent": "#FFD400",
		"accent_ink": "#000000",
	},
}

const CHIPS: Array = [
	{"color": "#E69F00", "letter": "A", "shape": "circle"},
	{"color": "#56B4E9", "letter": "B", "shape": "square"},
	{"color": "#009E73", "letter": "C", "shape": "triangle"},
	{"color": "#CC79A7", "letter": "D", "shape": "diamond"},
	{"color": "#0072B2", "letter": "E", "shape": "bar"},
	{"color": "#D55E00", "letter": "F", "shape": "plus"},
]


static func current() -> Dictionary:
	return colors(AppSettings.resolved_theme())


static func colors(theme_name: String = "warm") -> Dictionary:
	var key := theme_name if THEMES.has(theme_name) else "warm"
	var raw: Dictionary = THEMES[key]
	var out := {}
	for entry in raw.keys():
		out[entry] = Color(str(raw[entry]))
	return out


static func paint_action(button: Button, filled: bool) -> void:
	var palette := current()
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(16)
	var has_lock := button.get_node_or_null("LockMark") != null
	box.content_margin_left = 46 if has_lock else 16
	box.content_margin_right = 16
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT if has_lock else HORIZONTAL_ALIGNMENT_CENTER
	var ink: Color = palette["accent_ink"] if filled else palette["ink"]
	box.bg_color = palette["accent"] if filled else palette["surface"]
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, box)
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)


static func paint_back(button: Button) -> void:
	var palette := current()
	var box := StyleBoxFlat.new()
	box.bg_color = palette["surface"]
	box.set_corner_radius_all(14)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.border_color = palette["accent"]
	box.set_border_width_all(2)
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, box)
	var ink: Color = palette["ink"]
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)
	button.flat = false
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if button.text == "Back":
		button.text = "←  Back"


static func danger() -> Color:
	match AppSettings.resolved_theme():
		"night":
			return Color("#FF8F85")
		"contrast":
			return Color("#FFFFFF")
	return Color("#B3261E")


static func paint_scroll(scroll: ScrollContainer) -> void:
	var palette := current()
	var grab := StyleBoxFlat.new()
	grab.bg_color = palette["accent"]
	grab.set_corner_radius_all(6)
	var track := StyleBoxFlat.new()
	var track_color: Color = palette["muted"]
	track_color.a = 0.28
	track.bg_color = track_color
	track.set_corner_radius_all(6)
	var bar := scroll.get_v_scroll_bar()
	bar.custom_minimum_size.x = 8
	for style_name in ["grabber", "grabber_highlight", "grabber_pressed"]:
		bar.add_theme_stylebox_override(style_name, grab)
	for style_name in ["scroll", "scroll_focus"]:
		bar.add_theme_stylebox_override(style_name, track)


static func paint_progress(bar: ProgressBar, palette: Dictionary) -> void:
	var track := StyleBoxFlat.new()
	var track_color: Color = palette["muted"]
	track_color.a = 0.28
	track.bg_color = track_color
	track.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = palette["accent"]
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)


static func chip(index: int) -> Dictionary:
	var item: Dictionary = CHIPS[posmod(index, CHIPS.size())]
	return {
		"color": Color(str(item["color"])),
		"letter": str(item["letter"]),
		"shape": str(item["shape"]),
	}


static func chip_ink(index: int) -> Color:
	var bg: Color = chip(index)["color"]
	var black := Color(0, 0, 0, 1)
	var white := Color(1, 1, 1, 1)
	if ratio(black, bg) >= ratio(white, bg):
		return black
	return white


static func ratio(a: Color, b: Color) -> float:
	var lighter := maxf(_luminance(a), _luminance(b))
	var darker := minf(_luminance(a), _luminance(b))
	return (lighter + 0.05) / (darker + 0.05)


static func _luminance(color: Color) -> float:
	return 0.2126 * _channel(color.r) + 0.7152 * _channel(color.g) + 0.0722 * _channel(color.b)


static func _channel(value: float) -> float:
	if value <= 0.04045:
		return value / 12.92
	return pow((value + 0.055) / 1.055, 2.4)
