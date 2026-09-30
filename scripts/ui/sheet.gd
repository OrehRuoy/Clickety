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
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 56)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.add_theme_font_size_override("font_size", 18)
		var action := str(row.get("id", ""))
		button.pressed.connect(_pick.bind(action))
		_rows.add_child(button)
	visible = true


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
