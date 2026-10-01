extends Control

var _wordmark: TextureRect


func _ready() -> void:
	_wordmark = Mark.wordmark(240.0, 68.0)
	%Column.add_child(_wordmark)
	%Column.move_child(_wordmark, 1)
	%Back.pressed.connect(_on_back)
	Palette.paint_back(%Back)
	%Background.color = Palette.current()["bg"]
	AppSettings.changed.connect(_on_appearance)
	%Debug.visible = OS.is_debug_build() and not AppInfo.SCREENSHOT_MODE
	if OS.is_debug_build():
		%Pretend.button_pressed = Purchase.is_unlocked()
	%NewProject.pressed.connect(_on_new)
	%ArchivedToggle.pressed.connect(_on_archived_toggle)
	%Pretend.pressed.connect(_on_pretend)
	%Sample.pressed.connect(_on_sample)
	Purchase.unlocked_changed.connect(_on_unlocked_paint)
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	_fill()


func _on_appearance(key: String) -> void:
	if key != "theme" and key != "text_size":
		return
	%Background.color = Palette.current()["bg"]
	Mark.refresh_wordmark(_wordmark)
	Palette.paint_back(%Back)
	_fill()


func _fill() -> void:
	_clear(%List)
	_clear(%Archived)
	var active: Array = []
	var archived: Array = []
	for project in Store.projects():
		if typeof(project) != TYPE_DICTIONARY:
			continue
		if bool(project.get("archived", false)):
			archived.append(project)
		else:
			active.append(project)
	if active.is_empty():
		%List.add_child(Mark.brand(168.0, 148.0))
	for project in active:
		%List.add_child(_row(project))
	for project in archived:
		%Archived.add_child(_row(project))
	%ArchivedToggle.visible = not archived.is_empty()
	_paint_new()
	%ArchivedToggle.text = "Archived (%d)" % archived.size()


func _row(project: Dictionary) -> Button:
	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(0, 72)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.current()["surface"]
	style.set_corner_radius_all(12)
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	var craft := "hook" if str(project.get("craft", "knit")) == "crochet" else "needles"
	var mark := Mark.icon(craft, Palette.current()["accent"], 36.0)
	var text := VBoxContainer.new()
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	name_label.text = str(project.get("name", "Project"))
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var meta := Label.new()
	meta.text = _meta(project)
	meta.add_theme_font_size_override("font_size", 16)
	meta.add_theme_color_override("font_color", Palette.current()["muted"])
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(name_label)
	text.add_child(meta)
	var value := int(_main(project).get("value", 0))
	var target := int(project.get("target", 0))
	if target > 0:
		var bar := ProgressBar.new()
		bar.max_value = float(target)
		bar.value = float(mini(value, target))
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Palette.paint_progress(bar, Palette.current())
		text.add_child(bar)
	var value_label := Label.new()
	value_label.text = "%d of %d" % [value, target] if target > 0 else str(value)
	value_label.add_theme_font_size_override("font_size", 20)
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(mark)
	row.add_child(text)
	row.add_child(value_label)
	button.add_child(row)
	row.layout_mode = 1
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12
	row.offset_top = 8
	row.offset_right = -12
	row.offset_bottom = -8
	button.custom_minimum_size.y = 88 if target > 0 else 72
	var id := str(project.get("id", ""))
	button.pressed.connect(_open_project.bind(id))
	return button


func _meta(project: Dictionary) -> String:
	var craft := "Crochet" if str(project.get("craft", "")) == "crochet" else "Knit"
	var updated := int(project.get("updated", 0))
	if updated <= 0:
		return craft
	return "%s · last worked %s" % [craft, HistoryFormat.weekday(updated)]


func _main(project: Dictionary) -> Dictionary:
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return counter
	return {}


func _open_project(id: String) -> void:
	Store.set_active(id)
	get_tree().change_scene_to_file("res://scenes/counter.tscn")


func _paint_new() -> void:
	var locked := Store.projects().size() >= 1 and not Purchase.is_unlocked()
	%NewProject.alignment = HORIZONTAL_ALIGNMENT_CENTER
	%NewProject.text = "Unlock" if locked else "+ New project"
	Mark.show_lock(%NewProject, locked)
	Palette.paint_action(%NewProject, not locked)


func _on_unlocked_paint(_is_on: bool) -> void:
	_paint_new()


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/counter.tscn")


func _on_new() -> void:
	if Store.projects().size() >= 1 and not Purchase.is_unlocked():
		Purchase.set_intent("new_project", "projects")
		get_tree().change_scene_to_file("res://scenes/unlock.tscn")
		return
	var project := Store.create_project("Project", "knit")
	Store.begin_edit(str(project["id"]), "projects")
	get_tree().change_scene_to_file("res://scenes/project_edit.tscn")


func _on_archived_toggle() -> void:
	%Archived.visible = not %Archived.visible


func _on_pretend() -> void:
	if not OS.is_debug_build():
		return
	Purchase.set_pretend(%Pretend.button_pressed)
	%Pretend.set_pressed_no_signal(Purchase.is_unlocked())


func _on_sample() -> void:
	Store.load_sample()
	_fill()
	if OS.is_debug_build():
		%Pretend.button_pressed = Purchase.is_unlocked()


func _clear(box: Node) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.free()
