class_name ClickSheet
extends Control

signal picked(action: String)

@onready var _title: Label = %Title
@onready var _rows: VBoxContainer = %Rows


func _ready() -> void:
	visible = false
	_style_dim()
	_style_panel()
	%Dim.pressed.connect(_close)


func present(title: String, rows: Array) -> void:
	_style_panel()
	DisplayServer.virtual_keyboard_hide()
	_title.text = title
	_title.visible = title != ""
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.free()
	for row in rows:
		var button := Button.new()
		button.text = str(row.get("text", ""))
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.flat = true
		button.custom_minimum_size = Vector2(0, 52)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.add_theme_font_size_override("font_size", 20)
		var action := str(row.get("id", ""))
		var ink: Color = Palette.current()["muted"] if action == "cancel" else Palette.current()["ink"]
		button.add_theme_color_override("font_color", ink)
		button.add_theme_color_override("font_hover_color", ink)
		button.add_theme_color_override("font_pressed_color", ink)
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


func _style_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.current()["surface"]
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 20
	%Panel.add_theme_stylebox_override("panel", style)
