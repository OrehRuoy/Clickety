extends Control

var _project: Dictionary = {}
var _loading := false


func _ready() -> void:
	%Background.color = Palette.current()["bg"]
	AppSettings.changed.connect(_on_appearance)
	%Back.pressed.connect(_on_back)
	%Knit.pressed.connect(_set_craft.bind("knit"))
	%Crochet.pressed.connect(_set_craft.bind("crochet"))
	%TargetDown.pressed.connect(_step_target.bind(-1))
	%TargetUp.pressed.connect(_step_target.bind(1))
	%Name.text_changed.connect(_on_name)
	%Target.text_changed.connect(_on_target)
	%Notes.text_changed.connect(_on_notes)
	%ShowTimer.pressed.connect(_on_show_timer)
	%TimerRun.pressed.connect(_on_timer_run)
	%Reset.pressed.connect(_on_reset)
	%Delete.pressed.connect(_on_delete)
	%Archive.pressed.connect(_on_archive)
	%Counters.pressed.connect(_on_counters)
	%RowAlerts.pressed.connect(_on_alerts)
	%Sheet.picked.connect(_on_sheet)
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	_project = Store.project_by_id(Store.editing_id)
	if _project.is_empty():
		call_deferred("_on_back")
		return
	_load_fields()


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _load_fields() -> void:
	_loading = true
	%Name.text = str(_project.get("name", ""))
	%Name.max_length = 40
	%Target.text = str(maxi(0, int(_project.get("target", 0))))
	%Notes.text = str(_project.get("notes", ""))
	var timer = _project.get("timer", {})
	var shown := false
	if typeof(timer) == TYPE_DICTIONARY:
		shown = bool(timer.get("shown", false))
	%ShowTimer.button_pressed = shown
	_loading = false
	_paint_craft()
	_paint_timer()
	_paint_archive()
	_paint_history()


func _on_name(new_text: String) -> void:
	if _loading:
		return
	_project["name"] = new_text.substr(0, 40)
	Store.touch_project(_project)


func _on_target(_new_text: String) -> void:
	if _loading:
		return
	_project["target"] = _target_value()
	Store.touch_project(_project)


func _on_notes() -> void:
	if _loading:
		return
	var text: String = %Notes.text
	if text.length() > 2000:
		_loading = true
		%Notes.text = text.substr(0, 2000)
		_loading = false
		text = %Notes.text
	_project["notes"] = text
	Store.touch_project(_project)


func _set_craft(craft: String) -> void:
	_project["craft"] = craft
	Store.touch_project(_project)
	_paint_craft()


func _step_target(delta: int) -> void:
	var next := maxi(0, _target_value() + delta)
	_loading = true
	%Target.text = str(next)
	_loading = false
	_project["target"] = next
	Store.touch_project(_project)


func _target_value() -> int:
	var text: String = str(%Target.text).strip_edges()
	if not text.is_valid_int():
		return 0
	return maxi(0, int(text))


func _on_show_timer() -> void:
	if _loading:
		return
	var timer := _timer()
	timer["shown"] = %ShowTimer.button_pressed
	if not timer["shown"]:
		_stop_timer(timer)
	_project["timer"] = timer
	Store.touch_project(_project)
	_paint_timer()


func _on_timer_run() -> void:
	var timer := _timer()
	if int(timer.get("running_since", 0)) > 0:
		_stop_timer(timer)
	else:
		timer["running_since"] = int(Time.get_unix_time_from_system())
	_project["timer"] = timer
	Store.touch_project(_project)
	_paint_timer()


func _stop_timer(timer: Dictionary) -> void:
	var since := int(timer.get("running_since", 0))
	if since > 0:
		timer["total_sec"] = int(timer.get("total_sec", 0)) + maxi(0, int(Time.get_unix_time_from_system()) - since)
	timer["running_since"] = 0


func _timer() -> Dictionary:
	var timer = _project.get("timer", {})
	if typeof(timer) != TYPE_DICTIONARY:
		timer = {"shown": false, "running_since": 0, "total_sec": 0}
	return timer


func _paint_craft() -> void:
	var craft := str(_project.get("craft", "knit"))
	%Knit.modulate = Color(1, 1, 1, 1) if craft == "knit" else Color(1, 1, 1, 0.45)
	%Crochet.modulate = Color(1, 1, 1, 1) if craft == "crochet" else Color(1, 1, 1, 0.45)


func _paint_timer() -> void:
	var timer := _timer()
	var shown := bool(timer.get("shown", false))
	%TimerRun.visible = shown
	if int(timer.get("running_since", 0)) > 0:
		%TimerRun.text = "Pause · %s" % Store.elapsed_text(_project)
	else:
		%TimerRun.text = "Start · %s" % Store.elapsed_text(_project)


func _paint_archive() -> void:
	%Archive.text = "Unarchive" if bool(_project.get("archived", false)) else "Archive"


func _on_appearance(key: String) -> void:
	if key != "theme" and key != "text_size":
		return
	%Background.color = Palette.current()["bg"]
	if not _project.is_empty():
		_paint_history()


func _paint_history() -> void:
	for child in %History.get_children():
		%History.remove_child(child)
		child.free()
	var lines := HistoryFormat.lines(_project, 200)
	if lines.is_empty():
		var empty := Label.new()
		empty.text = "No rows yet"
		empty.add_theme_font_size_override("font_size", 18)
		empty.add_theme_color_override("font_color", Palette.current()["muted"])
		%History.add_child(empty)
		return
	for line in lines:
		var label := Label.new()
		label.text = line
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 18)
		%History.add_child(label)


func _on_reset() -> void:
	%Sheet.present("Reset the main counter to its start?", [
		{"id": "reset", "text": "Reset main counter"},
		{"id": "cancel", "text": "Cancel"},
	])


func _on_delete() -> void:
	%Sheet.present("This removes the project from the app. A copy is kept in Backups for 30 days.", [
		{"id": "delete", "text": "Delete project"},
		{"id": "cancel", "text": "Cancel"},
	])


func _on_archive() -> void:
	_project["archived"] = not bool(_project.get("archived", false))
	Store.touch_project(_project)
	_paint_archive()


func _on_sheet(action: String) -> void:
	if action == "reset":
		var counter := _main_counter()
		if not counter.is_empty():
			Store.reset_counter(str(_project.get("id", "")), str(counter.get("id", "")))
			_project = Store.project_by_id(Store.editing_id)
		_paint_history()
	elif action == "delete":
		Store.delete_project(str(_project.get("id", "")))
		get_tree().change_scene_to_file("res://scenes/projects.tscn")


func _main_counter() -> Dictionary:
	for counter in _project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return counter
	return {}


func _on_counters() -> void:
	Store.counters_return = "project"
	get_tree().change_scene_to_file("res://scenes/counters_edit.tscn")


func _on_alerts() -> void:
	get_tree().change_scene_to_file("res://scenes/row_alerts.tscn")


func _on_back() -> void:
	var path := "res://scenes/counter.tscn" if Store.edit_return == "counter" else "res://scenes/projects.tscn"
	get_tree().change_scene_to_file(path)
