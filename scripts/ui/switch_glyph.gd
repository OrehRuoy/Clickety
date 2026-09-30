class_name SwitchGlyph
extends Control

static var _blank: Texture2D

var _shown := false


static func attach(button: CheckButton) -> void:
	if button.get_node_or_null("SwitchGlyph") != null:
		return
	if _blank == null:
		var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))
		_blank = ImageTexture.create_from_image(image)
	for icon_name in ["checked", "unchecked", "checked_disabled", "unchecked_disabled", "checked_mirrored", "unchecked_mirrored", "checked_disabled_mirrored", "unchecked_disabled_mirrored"]:
		button.add_theme_icon_override(icon_name, _blank)
	var glyph := SwitchGlyph.new()
	glyph.name = "SwitchGlyph"
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyph.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	glyph.offset_left = -64.0
	glyph.offset_top = -16.0
	glyph.offset_right = -12.0
	glyph.offset_bottom = 16.0
	button.add_child(glyph)


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	var button := get_parent() as BaseButton
	if button != null and button.button_pressed != _shown:
		queue_redraw()


func _draw() -> void:
	var button := get_parent() as BaseButton
	_shown = button != null and button.button_pressed
	var palette := Palette.current()
	var radius := size.y * 0.5
	if radius < 1.0:
		return
	var accent: Color = palette["accent"]
	var knob: Color = palette["accent_ink"] if _shown else accent
	if _shown:
		_pill(accent, 0.0, radius)
	else:
		var cream: Color = palette["bg"]
		_pill(accent, 0.0, radius)
		_pill(cream, 3.0, radius)
	var knob_x := size.x - radius if _shown else radius
	draw_circle(Vector2(knob_x, radius), radius - 4.0, knob)


func _pill(color: Color, inset: float, radius: float) -> void:
	var cap := radius
	var inner := radius - inset
	if inner < 1.0:
		return
	draw_rect(Rect2(Vector2(cap, inset), Vector2(size.x - cap * 2.0, size.y - inset * 2.0)), color, true)
	draw_circle(Vector2(cap, cap), inner, color)
	draw_circle(Vector2(size.x - cap, cap), inner, color)
