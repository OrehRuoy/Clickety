extends Control

var _project: Dictionary = {}
var _editing_id := ""
var _kind := "at"
var _list: VBoxContainer
var _form: VBoxContainer
var _text: LineEdit
var _row: LineEdit
var _every: LineEdit
var _from: LineEdit
var _counter: OptionButton
var _error: Label
var _add: Button


func _ready() -> void:
	%Background.color = Palette.current()["bg"]
	AppSettings.changed.connect(_on_appearance)
	%Back.pressed.connect(_on_back)
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	_build()
	_project = Store.project_by_id(Store.editing_id)
	if _project.is_empty():
		call_deferred("_on_back")
		return
	_fill()
	if Store.open_alert_form:
		Store.open_alert_form = false
		_open_new()


func _build() -> void:
	var body: VBoxContainer = %Body
	_add = Button.new()
	var add := _add
	_paint_add()
	add.alignment = HORIZONTAL_ALIGNMENT_LEFT
	add.custom_minimum_size = Vector2(0, 56)
	add.focus_mode = Control.FOCUS_NONE
	add.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	add.pressed.connect(_on_add)
	body.add_child(add)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	body.add_child(_list)
	_form = VBoxContainer.new()
	_form.visible = false
	_form.add_theme_constant_override("separation", 8)
	body.add_child(_form)
	_text = _field(_form, "Decrease")
	_row = _field(_form, "40")
	_every = _field(_form, "6")
	_from = _field(_form, "0")
	_counter = OptionButton.new()
	_counter.custom_minimum_size = Vector2(0, 56)
	_counter.focus_mode = Control.FOCUS_NONE
	_form.add_child(_counter)
	var kinds := HBoxContainer.new()
	kinds.add_theme_constant_override("separation", 8)
	_form.add_child(kinds)
	var at_button := _button("At row N")
	at_button.pressed.connect(_set_kind.bind("at"))
	kinds.add_child(at_button)
	var every_button := _button("Every N rows")
	every_button.pressed.connect(_set_kind.bind("every"))
	kinds.add_child(every_button)
	var save := _button("Save")
	save.pressed.connect(_on_save)
	_form.add_child(save)
	var cancel := _button("Cancel")
	cancel.pressed.connect(_show_list)
	_form.add_child(cancel)
	_error = Label.new()
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error.add_theme_color_override("font_color", Palette.current()["accent"])
	_form.add_child(_error)


func _field(parent: VBoxContainer, placeholder: String) -> LineEdit:
	var field := LineEdit.new()
	field.placeholder_text = placeholder
	field.custom_minimum_size = Vector2(0, 56)
	parent.add_child(field)
	return field


func _button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


func _fill() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.free()
	_fill_counters()
	for alert in _project.get("alerts", []):
		if typeof(alert) != TYPE_DICTIONARY:
			continue
		_list.add_child(_row_for(alert))


func _row_for(alert: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = "%s\n%s" % [str(alert.get("text", "Alert")), _rule(alert)]
	row.add_child(label)
	var edit := _button("Edit")
	edit.pressed.connect(_open_edit.bind(str(alert.get("id", ""))))
	row.add_child(edit)
	var remove := _button("Delete")
	remove.pressed.connect(_on_delete.bind(str(alert.get("id", ""))))
	row.add_child(remove)
	return row


func _rule(alert: Dictionary) -> String:
	if str(alert.get("kind", "")) == "every":
		return "Every %d rows after %d" % [int(alert.get("every", 1)), int(alert.get("from", 0))]
	var suffix := " · done" if bool(alert.get("done", false)) else ""
	return "At row %d%s" % [int(alert.get("row", 0)), suffix]


func _fill_counters() -> void:
	_counter.clear()
	for counter in _project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY:
			continue
		_counter.add_item(str(counter.get("name", "Counter")))
		_counter.set_item_metadata(_counter.item_count - 1, str(counter.get("id", "")))


func _on_add() -> void:
	if not Purchase.is_unlocked():
		Purchase.set_intent("add_alert", "alerts")
		get_tree().change_scene_to_file("res://scenes/unlock.tscn")
		return
	_open_new()


func _open_new() -> void:
	_editing_id = ""
	_kind = "at"
	_text.text = ""
	_row.text = ""
	_every.text = "6"
	_from.text = "0"
	_error.text = ""
	_select_counter(_main_id())
	_show_form()


func _open_edit(alert_id: String) -> void:
	for alert in _project.get("alerts", []):
		if typeof(alert) == TYPE_DICTIONARY and str(alert.get("id", "")) == alert_id:
			_editing_id = alert_id
			_kind = "every" if str(alert.get("kind", "")) == "every" else "at"
			_text.text = str(alert.get("text", ""))
			_row.text = str(int(alert.get("row", 0)))
			_every.text = str(int(alert.get("every", 6)))
			_from.text = str(int(alert.get("from", 0)))
			_error.text = ""
			_select_counter(str(alert.get("counter_id", "")))
			_show_form()
			return


func _show_form() -> void:
	_list.visible = false
	_form.visible = true
	_row.visible = _kind == "at"
	_every.visible = _kind == "every"
	_from.visible = _kind == "every"


func _show_list() -> void:
	_form.visible = false
	_list.visible = true
	_project = Store.project_by_id(Store.editing_id)
	_fill()


func _set_kind(kind: String) -> void:
	_kind = kind
	_show_form()


func _on_save() -> void:
	var text := _text.text.strip_edges()
	if text == "":
		_error.text = "Add a short note, like Decrease or Buttonhole."
		return
	var alert := {
		"id": _editing_id,
		"kind": _kind,
		"counter_id": _selected_counter(),
		"text": text,
		"done": _kept_done(),
	}
	if _kind == "at":
		if not _row.text.is_valid_int():
			_error.text = "Use a row number."
			return
		alert["row"] = int(_row.text)
	else:
		if not _every.text.is_valid_int() or int(_every.text) < 1:
			_error.text = "Use a number of rows."
			return
		if not _from.text.is_valid_int():
			_error.text = "Use a starting row."
			return
		alert["every"] = int(_every.text)
		alert["from"] = int(_from.text)
	Store.save_alert(str(_project.get("id", "")), alert)
	_show_list()


func _on_delete(alert_id: String) -> void:
	Store.delete_alert(str(_project.get("id", "")), alert_id)
	_project = Store.project_by_id(Store.editing_id)
	_fill()


func _kept_done() -> bool:
	if _editing_id == "" or _kind != "at":
		return false
	for alert in _project.get("alerts", []):
		if typeof(alert) == TYPE_DICTIONARY and str(alert.get("id", "")) == _editing_id:
			return bool(alert.get("done", false))
	return false


func _selected_counter() -> String:
	if _counter.item_count == 0:
		return ""
	return str(_counter.get_item_metadata(_counter.selected))


func _select_counter(counter_id: String) -> void:
	for index in _counter.item_count:
		if str(_counter.get_item_metadata(index)) == counter_id:
			_counter.select(index)
			return
	if _counter.item_count > 0:
		_counter.select(0)


func _main_id() -> String:
	for counter in _project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return str(counter.get("id", ""))
	return ""


func _on_appearance(key: String) -> void:
	if key == "theme" or key == "text_size":
		%Background.color = Palette.current()["bg"]


func _paint_add() -> void:
	if _add == null:
		return
	var locked := not Purchase.is_unlocked()
	_add.text = "Unlock" if locked else "Add alert"
	Mark.show_lock(_add, locked)
	Palette.paint_action(_add, not locked)


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _on_back() -> void:
	if _form.visible:
		_show_list()
		return
	get_tree().change_scene_to_file("res://scenes/project_edit.tscn")
