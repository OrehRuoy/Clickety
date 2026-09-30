extends Control

var _project: Dictionary = {}
var _mode := ""
var _editing_id := ""
var _delete_id := ""
var _loading := false


func _ready() -> void:
	_paint_theme()
	AppSettings.changed.connect(_on_appearance)
	%Back.pressed.connect(_on_back)
	%Add.pressed.connect(_on_add)
	%RepeatPreset.pressed.connect(_open_repeat)
	%IndependentPreset.pressed.connect(_open_independent)
	%CustomPreset.pressed.connect(_open_custom)
	%PresetCancel.pressed.connect(_show_list)
	%FormCancel.pressed.connect(_show_list)
	%Save.pressed.connect(_on_save)
	%Name.text_changed.connect(_on_form_changed)
	%N.text_changed.connect(_on_form_changed)
	%Start.text_changed.connect(_on_form_changed)
	%Step.text_changed.connect(_on_form_changed)
	%Wraps.text_changed.connect(_on_form_changed)
	%Follows.item_selected.connect(_on_follows_selected)
	%On.item_selected.connect(_on_form_changed_index)
	%Sheet.picked.connect(_on_sheet)
	%On.clear()
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	%On.add_item("On step")
	%On.add_item("On wrap")
	_paint_add()
	_project = Store.project_by_id(Store.editing_id)
	if _project.is_empty():
		call_deferred("_on_back")
		return
	_show_list()
	if Purchase.take_open_presets():
		_on_add()


func _paint_theme() -> void:
	var palette := Palette.current()
	%Background.color = palette["bg"]
	%Error.add_theme_color_override("font_color", palette["accent"])


func _on_appearance(key: String) -> void:
	if key != "theme" and key != "text_size":
		return
	_paint_theme()
	if not _project.is_empty():
		_fill()


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _paint_add() -> void:
	for child in %Add.get_children():
		%Add.remove_child(child)
		child.free()
	var locked := not Purchase.is_unlocked()
	%Add.text = "Unlock" if locked else "+ Add counter"
	Mark.show_lock(%Add, locked)
	Palette.paint_action(%Add, not locked)


func _show_list() -> void:
	_mode = ""
	_editing_id = ""
	%Presets.visible = false
	%Form.visible = false
	%List.visible = true
	%Add.visible = true
	_project = Store.project_by_id(Store.editing_id)
	_fill()


func _fill() -> void:
	for child in %List.get_children():
		%List.remove_child(child)
		child.free()
	var counters := _ordered(_project)
	for counter in counters:
		%List.add_child(_row(counter))


func _ordered(project: Dictionary) -> Array:
	var main: Array = []
	var extra: Array = []
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY:
			continue
		if str(counter.get("role", "")) == "main":
			main.append(counter)
		else:
			extra.append(counter)
	return main + extra


func _row(counter: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.current()["surface"]
	style.set_corner_radius_all(12)
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	var body := HBoxContainer.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_theme_constant_override("separation", 10)
	body.add_child(_badge(counter))
	var text := VBoxContainer.new()
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 20)
	title.text = "%s  %d" % [str(counter.get("name", "Counter")), int(counter.get("value", 0))]
	var rule := Label.new()
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.add_theme_font_size_override("font_size", 16)
	rule.add_theme_color_override("font_color", Palette.current()["muted"])
	rule.text = _rule(counter)
	text.add_child(title)
	text.add_child(rule)
	body.add_child(text)
	button.add_child(body)
	body.layout_mode = 1
	body.set_anchors_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 12
	body.offset_top = 8
	body.offset_right = -12
	body.offset_bottom = -8
	var id := str(counter.get("id", ""))
	button.pressed.connect(_open_edit.bind(id))
	row.add_child(button)
	if str(counter.get("role", "")) != "main":
		var remove := Button.new()
		remove.text = "Delete"
		remove.custom_minimum_size = Vector2(96, 56)
		remove.focus_mode = Control.FOCUS_NONE
		remove.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		remove.add_theme_font_size_override("font_size", 18)
		remove.pressed.connect(_ask_delete.bind(id))
		row.add_child(remove)
	return row


func _badge(counter: Dictionary) -> Panel:
	var chip: Dictionary = Palette.chip(int(counter.get("color_idx", 0)))
	var badge := Panel.new()
	badge.custom_minimum_size = Vector2(36, 36)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := StyleBoxFlat.new()
	panel.bg_color = chip["color"]
	panel.set_corner_radius_all(8)
	badge.add_theme_stylebox_override("panel", panel)
	var letter := Label.new()
	letter.text = str(chip.get("letter", "A"))
	letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	letter.add_theme_color_override("font_color", Palette.chip_ink(int(counter.get("color_idx", 0))))
	letter.layout_mode = 1
	letter.set_anchors_preset(Control.PRESET_FULL_RECT)
	badge.add_child(letter)
	return badge


func _rule(counter: Dictionary) -> String:
	var link = counter.get("link", {})
	if typeof(link) != TYPE_DICTIONARY or str(link.get("to", "")) == "":
		return "independent"
	var target := _name_of(str(link.get("to", "")))
	if str(link.get("on", "")) == "wrap":
		return "counts wraps of %s" % target
	var reset_at := int(counter.get("reset_at", 0))
	if reset_at > 0:
		return "follows %s, 1–%d" % [target, reset_at]
	return "follows %s" % target


func _name_of(counter_id: String) -> String:
	for counter in _project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("id", "")) == counter_id:
			return str(counter.get("name", "Counter"))
	return "Counter"


func _on_add() -> void:
	if not Purchase.is_unlocked():
		Purchase.set_intent("add_counter", "counters")
		get_tree().change_scene_to_file("res://scenes/unlock.tscn")
		return
	%List.visible = false
	%Add.visible = false
	%Form.visible = false
	%Presets.visible = true


func _open_repeat() -> void:
	_mode = "repeat"
	_editing_id = ""
	_show_form("Repeat every N rows")


func _open_independent() -> void:
	_mode = "independent"
	_editing_id = ""
	_show_form("Independent counter")


func _open_custom() -> void:
	_mode = "custom"
	_editing_id = ""
	_show_form("Custom")


func _open_edit(counter_id: String) -> void:
	_mode = "edit"
	_editing_id = counter_id
	_show_form("Edit counter")
	var counter := _counter(counter_id)
	_loading = true
	%Name.text = str(counter.get("name", ""))
	%Start.text = str(int(counter.get("start", 0)))
	%Step.text = str(int(counter.get("step", 1)))
	%Wraps.text = str(int(counter.get("reset_at", 0)))
	_select_follow(counter)
	_loading = false
	_refresh_form()


func _show_form(title: String) -> void:
	%List.visible = false
	%Add.visible = false
	%Presets.visible = false
	%Form.visible = true
	%FormTitle.text = title
	var custom := _mode == "custom" or _mode == "edit"
	%Name.visible = _mode != "repeat"
	%N.visible = _mode == "repeat"
	%Start.visible = custom
	%Step.visible = custom
	%Wraps.visible = custom
	%Follows.visible = custom
	%On.visible = custom
	_loading = true
	%Name.text = ""
	%N.text = "8"
	%Start.text = "0"
	%Step.text = "1"
	%Wraps.text = "0"
	_fill_follows("")
	%On.select(0)
	_loading = false
	_refresh_form()


func _fill_follows(selected_id: String) -> void:
	%Follows.clear()
	%Follows.add_item("Follows: none")
	%Follows.set_item_metadata(0, "")
	var pick := 0
	for counter in _ordered(_project):
		var id := str(counter.get("id", ""))
		if id == _editing_id:
			continue
		%Follows.add_item("Follows: %s" % str(counter.get("name", "Counter")))
		var item: int = %Follows.item_count - 1
		%Follows.set_item_metadata(item, id)
		if id == selected_id:
			pick = item
	%Follows.select(pick)


func _select_follow(counter: Dictionary) -> void:
	var link = counter.get("link", {})
	var target := ""
	var on := "step"
	if typeof(link) == TYPE_DICTIONARY:
		target = str(link.get("to", ""))
		on = str(link.get("on", "step"))
	_fill_follows(target)
	%On.select(1 if on == "wrap" else 0)
	%On.visible = target != ""


func _on_follows_selected(_index: int) -> void:
	if _loading:
		return
	%On.visible = _follow_id() != ""
	_refresh_form()


func _on_form_changed(_text: String = "") -> void:
	if _loading:
		return
	_refresh_form()


func _on_form_changed_index(_index: int) -> void:
	_on_form_changed("")


func _refresh_form() -> void:
	var message := ""
	if _mode == "repeat":
		var n := _number(%N.text)
		if n < 2 or n > 200:
			message = "Use a number from 2 to 200."
	elif _mode == "independent" or _mode == "custom" or _mode == "edit":
		if str(%Name.text).strip_edges() == "":
			message = "Give this counter a name."
		elif _mode != "independent":
			message = _plain(Store.check_counter(Store.editing_id, _draft(), _editing_id))
	%Error.text = message
	%Error.visible = message != ""
	%Save.disabled = message != ""


func _draft() -> Dictionary:
	var counter := {
		"id": _editing_id,
		"name": str(%Name.text).strip_edges().substr(0, 40),
		"start": _number(%Start.text),
		"step": maxi(1, _number(%Step.text)),
		"reset_at": maxi(0, _number(%Wraps.text)),
		"value": _kept_value(),
		"link": {},
	}
	var target := _follow_id()
	if target != "":
		counter["link"] = {"to": target, "on": "wrap" if %On.selected == 1 else "step"}
	return counter


func _kept_value() -> int:
	if _editing_id == "":
		return _number(%Start.text)
	return int(_counter(_editing_id).get("value", 0))


func _follow_id() -> String:
	var selected: int = %Follows.selected
	if selected < 0:
		return ""
	return str(%Follows.get_item_metadata(selected))


func _number(text: String) -> int:
	var clean := text.strip_edges()
	if not clean.is_valid_int():
		return 0
	return int(clean)


func _on_save() -> void:
	if %Save.disabled:
		return
	var errors: Array = []
	if _mode == "repeat":
		errors = Store.add_repeat_pair(Store.editing_id, _number(%N.text))
	elif _mode == "independent":
		var counter := Schema.new_counter(str(%Name.text).strip_edges(), "extra")
		counter["value"] = 0
		counter["start"] = 0
		counter["step"] = 1
		counter["link"] = {}
		errors = Store.add_counter(Store.editing_id, counter)
	elif _mode == "edit":
		errors = Store.update_counter(Store.editing_id, _draft())
	else:
		var created := Schema.new_counter(str(%Name.text).strip_edges(), "extra")
		var draft := _draft()
		created["name"] = draft["name"]
		created["start"] = draft["start"]
		created["step"] = draft["step"]
		created["reset_at"] = draft["reset_at"]
		created["value"] = draft["start"]
		created["link"] = draft["link"]
		errors = Store.add_counter(Store.editing_id, created)
	if not errors.is_empty():
		%Error.text = _plain(errors)
		%Error.visible = true
		%Save.disabled = true
		return
	_show_list()


func _ask_delete(counter_id: String) -> void:
	_delete_id = counter_id
	%Sheet.present("Delete %s?" % _name_of(counter_id), [
		{"id": "delete", "text": "Delete counter"},
		{"id": "cancel", "text": "Cancel"},
	])


func _on_sheet(action: String) -> void:
	if action != "delete":
		return
	Store.delete_counter(Store.editing_id, _delete_id)
	_delete_id = ""
	_show_list()


func _plain(errors: Array) -> String:
	var lines: PackedStringArray = []
	for raw in errors:
		var text := str(raw)
		if text.begins_with("self-link"):
			lines.append("A counter can't follow itself.")
		elif text.begins_with("missing"):
			lines.append("That counter no longer exists.")
		elif text.begins_with("wrap-link"):
			lines.append("A wrap can only follow a counter that wraps.")
		elif text == "loop":
			lines.append("These links go in a circle.")
		elif text == "n":
			lines.append("Use a number from 2 to 200.")
		elif text != "":
			lines.append(text)
	return "\n".join(lines)


func _counter(counter_id: String) -> Dictionary:
	for counter in _project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("id", "")) == counter_id:
			return counter
	return {}


func _on_back() -> void:
	var path := "res://scenes/counter.tscn" if Store.counters_return == "counter" else "res://scenes/project_edit.tscn"
	get_tree().change_scene_to_file(path)
