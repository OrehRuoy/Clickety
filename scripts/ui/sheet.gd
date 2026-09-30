class_name ClickSheet
extends Control

signal picked(action: String)

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	visible = false
	_style_dim()
	_style_panel()
	var handle := Control.new()
	handle.name = "Handle"
	handle.custom_minimum_size = Vector2(0, 18)
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handle.draw.connect(_draw_handle.bind(handle))
	var body := %Panel.get_node("Body") as VBoxContainer
	body.add_child(handle)
	body.move_child(handle, 0)
	%Dim.pressed.connect(_close)


func present(title: String, rows: Array) -> void:
	_style_panel()
	DisplayServer.virtual_keyboard_hide()
	_title.text = title
	_title.visible = title != ""
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Palette.current()["ink"])
	_rows.add_theme_constant_override("separation", 8)
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.free()
	for row in rows:
		var action := str(row.get("id", ""))
		var button := Button.new()
		button.text = str(row.get("text", ""))
		button.custom_minimum_size = Vector2(0, 56)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		button.add_theme_font_size_override("font_size", 20)
		_paint_row(button, action)
		button.pressed.connect(_pick.bind(action))
		_rows.add_child(button)
	visible = true
	call_deferred("_fit_panel")


func _fit_panel() -> void:
	var height: float = %Panel.get_combined_minimum_size().y + _home_inset()
	%Panel.offset_top = -height


func _home_inset() -> float:
	if OS.get_name() != "iOS":
		return 8.0
	var win := Vector2(DisplayServer.window_get_size())
	if win.y <= 0.0:
		return 8.0
	var safe := DisplayServer.get_display_safe_area()
	var visible := get_viewport().get_visible_rect().size
	return maxf(8.0, (win.y - safe.end.y) * visible.y / win.y)


func _pick(action: String) -> void:
	visible = false
	if action != "cancel":
		picked.emit(action)


func _close() -> void:
	visible = false


func _style_dim() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.45)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		%Dim.add_theme_stylebox_override(state, style)


func _paint_row(button: Button, action: String) -> void:
	var palette := Palette.current()
	var cancel := action == "cancel"
	var danger := action == "delete" or action == "reset"
	var ink: Color = palette["ink"]
	if cancel:
		ink = palette["muted"]
	elif danger:
		ink = Palette.danger()
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER if cancel else HORIZONTAL_ALIGNMENT_LEFT
	button.flat = cancel
	if cancel:
		button.add_theme_color_override("font_color", ink)
		button.add_theme_color_override("font_hover_color", ink)
		button.add_theme_color_override("font_pressed_color", ink)
		return
	var normal := AppTheme.card(palette, 14)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	var pressed := AppTheme.card(palette, 14)
	pressed.content_margin_left = 18
	pressed.content_margin_right = 18
	pressed.content_margin_top = 12
	pressed.content_margin_bottom = 12
	var wash: Color = Palette.danger() if danger else palette["accent"]
	wash.a = 0.16
	pressed.bg_color = wash
	pressed.border_color = Palette.danger() if danger else palette["accent"]
	for state in ["normal", "hover", "focus"]:
		button.add_theme_stylebox_override(state, normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)


func _draw_handle(handle: Control) -> void:
	var color: Color = Palette.current()["muted"]
	color.a = 0.45
	var width := 42.0
	var left := (handle.size.x - width) * 0.5
	handle.draw_rect(Rect2(left, 8, width, 4), color, true)


func _style_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.current()["bg"]
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 12
	%Panel.add_theme_stylebox_override("panel", style)
	var handle := %Panel.get_node_or_null("Body/Handle") as Control
	if handle != null:
		handle.queue_redraw()
