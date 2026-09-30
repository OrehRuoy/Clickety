extends Control

var _message: Label
var _preview: Label
var _add: Button
var _replace: Button
var _rows: Array[Button] = []
var _files: Array[Button] = []
var _list: VBoxContainer
var _selected: Dictionary = {}
var _sheet: ClickSheet
var _dialog: FileDialog


func _ready() -> void:
	%Back.pressed.connect(_on_back)
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	_build()
	_reload()
	AppSettings.changed.connect(_paint)
	_paint()


func _build() -> void:
	var body: VBoxContainer = %Body
	_message = _label(body, "")
	_message.visible = false
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	body.add_child(_list)
	if OS.get_name() != "iOS":
		_choice(body, "Choose a file", _on_choose)
		_dialog = FileDialog.new()
		_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_dialog.filters = PackedStringArray(["*.json ; JSON"])
		_dialog.file_selected.connect(_on_file_picked)
		add_child(_dialog)
	_preview = _label(body, "")
	_preview.visible = false
	_add = _choice(body, "Add these projects", _on_add)
	_replace = _choice(body, "Replace everything", _on_replace_ask)
	_add.disabled = true
	_replace.disabled = true
	var sheet := preload("res://scenes/components/sheet.tscn").instantiate()
	add_child(sheet)
	_sheet = sheet
	_sheet.picked.connect(_on_sheet)


func _reload() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.free()
	_files.clear()
	for item in Backup.list_files("user://"):
		var row: Dictionary = item
		var button := Button.new()
		button.text = str(row.get("label", ""))
		button.custom_minimum_size = Vector2(0, 56)
		button.focus_mode = Control.FOCUS_NONE
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_pick.bind(str(row.get("path", ""))))
		_list.add_child(button)
		_files.append(button)
	_paint()


func _on_pick(path: String) -> void:
	_show_parsed(Backup.parse_file(path))


func _on_choose() -> void:
	if _dialog != null:
		_dialog.popup_centered_ratio(0.8)


func _on_file_picked(path: String) -> void:
	_show_parsed(Backup.parse_file(path))


func _show_parsed(parsed: Dictionary) -> void:
	if not bool(parsed.get("ok", false)):
		_selected = {}
		_preview.visible = false
		_add.disabled = true
		_replace.disabled = true
		_message.text = "This file isn't a Clickety backup."
		_message.visible = true
		_paint()
		return
	_selected = parsed
	_message.visible = false
	_preview.text = Backup.preview(parsed)
	_preview.visible = true
	_add.disabled = false
	_replace.disabled = false
	_paint()


func _on_add() -> void:
	if _selected.is_empty():
		return
	Store.apply_restore(_selected, "add")
	_done()


func _on_replace_ask() -> void:
	if _selected.is_empty():
		return
	_sheet.present("Replace everything?", [
		{"id": "replace", "text": "Replace everything"},
		{"id": "cancel", "text": "Cancel"},
	])


func _on_sheet(action: String) -> void:
	if action != "replace" or _selected.is_empty():
		return
	Store.apply_restore(_selected, "replace")
	_done()


func _done() -> void:
	_selected = {}
	_preview.visible = false
	_add.disabled = true
	_replace.disabled = true
	_message.text = "Restored."
	_message.visible = true
	_reload()


func _label(parent: Container, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label


func _choice(parent: Container, text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(handler)
	parent.add_child(button)
	_rows.append(button)
	return button


func _paint() -> void:
	var palette := Palette.current()
	%Background.color = palette["bg"]
	_message.add_theme_color_override("font_color", palette["accent"])
	_preview.add_theme_color_override("font_color", palette["ink"])
	for button in _rows:
		_style_button(button, palette)
	for button in _files:
		_style_button(button, palette)


func _style_button(button: Button, palette: Dictionary) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = palette["surface"]
	box.set_corner_radius_all(12)
	box.content_margin_left = 16
	box.content_margin_right = 16
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, box)
	button.add_theme_color_override("font_color", palette["ink"])
	button.add_theme_color_override("font_disabled_color", palette["muted"])


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
