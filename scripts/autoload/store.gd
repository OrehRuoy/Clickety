extends Node

signal changed(project_id)
signal wrapped(project_id, counter_ids)
signal alerted(texts: Array)

const DATA_DIR := "user://data"
const FILE_NAME := "projects.json"

var _data: Dictionary = {}
var _dirty := false
var _save_queued := false
var editing_id := ""
var edit_return := "counter"
var counters_return := "project"
var open_alert_form := false
var _pending_alert_texts: Array = []


func _ready() -> void:
	_data = load_from_dir(DATA_DIR)
	if OS.is_debug_build():
		print("Clickety data: ", ProjectSettings.globalize_path(DATA_DIR))
	if projects().is_empty():
		create_project("My project", "knit")
	_prune_deleted()
	merge_widget_pending()
	if OS.get_name() == "iOS":
		get_tree().create_timer(0.4).timeout.connect(merge_widget_pending)
	Backup.keep_daily("user://", _data)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED \
			or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_pause_timers()
		save_now()
		WidgetSync.flush_now()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		merge_widget_pending()
		NotifyService.reschedule()


func active_project() -> Dictionary:
	var active_id := str(_data.get("active_project_id", ""))
	for project in _data.get("projects", []):
		if str(project.get("id", "")) == active_id:
			return project
	return {}


func set_active(id: String) -> void:
	_data["active_project_id"] = id
	mark_dirty()
	changed.emit(id)


func snapshot() -> Dictionary:
	return _data.duplicate(true)


func apply_restore(parsed: Dictionary, mode: String) -> void:
	Backup.write_safety("user://", _data, AppSettings.snapshot())
	var incoming: Dictionary = parsed.get("projects", {})
	if mode == "replace":
		_data = incoming.duplicate(true)
		if bool(parsed.get("apply_settings", false)):
			AppSettings.apply_snapshot(parsed.get("settings", {}))
	else:
		_data = Backup.add_projects(_data, incoming)
	mark_dirty()
	save_now()
	changed.emit(str(_data.get("active_project_id", "")))


func projects() -> Array:
	return _data.get("projects", [])


func hints() -> Dictionary:
	var raw = _data.get("hints", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return raw.duplicate(true)


func set_hint(key: String, value) -> void:
	var raw := hints()
	raw[key] = value
	_data["hints"] = raw
	mark_dirty()


func create_project(project_name: String, craft: String) -> Dictionary:
	var project := Schema.new_project(project_name, craft)
	var list: Array = _data.get("projects", [])
	list.append(project)
	_data["projects"] = list
	if str(_data.get("active_project_id", "")) == "":
		_data["active_project_id"] = project["id"]
	_touch(project)
	changed.emit(project["id"])
	return project


func delete_project(id: String) -> void:
	var list: Array = _data.get("projects", [])
	var kept: Array = []
	var removed: Dictionary = {}
	for project in list:
		if str(project.get("id", "")) == id and removed.is_empty():
			removed = project
		else:
			kept.append(project)
	if removed.is_empty():
		return
	_write_deleted_copy(removed)
	_data["projects"] = kept
	if str(_data.get("active_project_id", "")) == id:
		_data["active_project_id"] = str(kept[0]["id"]) if not kept.is_empty() else ""
	mark_dirty()
	changed.emit(str(_data.get("active_project_id", "")))


func tap(counter_id: String) -> void:
	_mutate(counter_id, "tap")


func minus(counter_id: String) -> void:
	_mutate(counter_id, "minus")


func undo() -> void:
	var project := active_project()
	if project.is_empty():
		return
	_apply(project, CounterLogic.undo(project))


func project_by_id(id: String) -> Dictionary:
	for project in _data.get("projects", []):
		if str(project.get("id", "")) == id:
			return project
	return {}


func begin_edit(id: String, return_to: String) -> void:
	editing_id = id
	edit_return = return_to


func touch_project(project: Dictionary) -> void:
	if project.is_empty():
		return
	_touch(project)
	changed.emit(str(project.get("id", "")))


func reset_counter(project_id: String, counter_id: String) -> void:
	var project := project_by_id(project_id)
	if project.is_empty():
		return
	_apply(project, CounterLogic.reset(project, counter_id))


func set_focus(project_id: String, counter_id: String) -> void:
	var project := project_by_id(project_id)
	if project.is_empty():
		return
	var main := _main_counter(project)
	var next := ""
	if counter_id != "" and counter_id != str(main.get("id", "")) and not _counter_by_id(project, counter_id).is_empty():
		next = counter_id
	if str(project.get("focus_id", "")) == next:
		return
	project["focus_id"] = next
	_touch(project)
	changed.emit(project_id)


func add_repeat_pair(project_id: String, n: int) -> Array:
	if n < 2 or n > 200:
		return ["n"]
	var project := project_by_id(project_id)
	if project.is_empty():
		return ["missing project"]
	var main := _main_counter(project)
	if main.is_empty():
		return ["missing project"]
	var pattern := Schema.new_counter("Pattern row", "extra")
	pattern["start"] = 1
	pattern["value"] = 1
	pattern["reset_at"] = n
	pattern["link"] = {"to": str(main.get("id", "")), "on": "step"}
	pattern["color_idx"] = _next_color(project)
	var repeats := Schema.new_counter("Repeats", "extra")
	repeats["link"] = {"to": str(pattern.get("id", "")), "on": "wrap"}
	repeats["color_idx"] = int(pattern["color_idx"]) + 1
	return _commit_counters(project, _counters_of(project) + [pattern, repeats])


func add_counter(project_id: String, counter: Dictionary) -> Array:
	var project := project_by_id(project_id)
	if project.is_empty():
		return ["missing project"]
	var prepared := _prepare_counter(counter, "extra", _next_color(project))
	prepared["color_idx"] = _next_color(project)
	return _commit_counters(project, _counters_of(project) + [prepared])


func update_counter(project_id: String, counter: Dictionary) -> Array:
	var project := project_by_id(project_id)
	if project.is_empty():
		return ["missing project"]
	var counter_id := str(counter.get("id", ""))
	var existing := _counter_by_id(project, counter_id)
	if existing.is_empty():
		return ["missing target: %s" % counter_id]
	var role := str(existing.get("role", "extra"))
	var prepared := _prepare_counter(counter, role, int(existing.get("color_idx", 0)))
	prepared["id"] = counter_id
	prepared["color_idx"] = int(existing.get("color_idx", 0))
	var next: Array = []
	for item in _counters_of(project):
		if str(item.get("id", "")) == counter_id:
			next.append(prepared)
		else:
			next.append(item)
	return _commit_counters(project, next)


func delete_counter(project_id: String, counter_id: String) -> bool:
	var project := project_by_id(project_id)
	if project.is_empty():
		return false
	var removed := _counter_by_id(project, counter_id)
	if removed.is_empty() or str(removed.get("role", "")) == "main":
		return false
	var removed_link = removed.get("link", {})
	var removed_on := ""
	var removed_to := ""
	if typeof(removed_link) == TYPE_DICTIONARY:
		removed_on = str(removed_link.get("on", ""))
		removed_to = str(removed_link.get("to", ""))
	var kept: Array = []
	for item in _counters_of(project):
		if str(item.get("id", "")) == counter_id:
			continue
		var link = item.get("link", {})
		if typeof(link) == TYPE_DICTIONARY and str(link.get("to", "")) == counter_id:
			var on := str(link.get("on", ""))
			if removed_to != "" and on == removed_on and (on == "step" or on == "wrap"):
				item["link"] = {"to": removed_to, "on": on}
			else:
				item["link"] = {}
		kept.append(item)
	project["counters"] = kept
	if str(project.get("focus_id", "")) == counter_id:
		project["focus_id"] = ""
	_touch(project)
	changed.emit(project_id)
	return true


func check_counter(project_id: String, counter: Dictionary, replacing_id: String = "") -> Array:
	var project := project_by_id(project_id)
	if project.is_empty():
		return ["missing project"]
	var counters := _counters_of(project)
	if replacing_id == "":
		var prepared := _prepare_counter(counter, "extra", _next_color(project))
		prepared["color_idx"] = _next_color(project)
		counters.append(prepared)
	else:
		var existing := _counter_by_id(project, replacing_id)
		if existing.is_empty():
			return ["missing target: %s" % replacing_id]
		var prepared := _prepare_counter(counter, str(existing.get("role", "extra")), int(existing.get("color_idx", 0)))
		prepared["id"] = replacing_id
		prepared["color_idx"] = int(existing.get("color_idx", 0))
		var next: Array = []
		for item in counters:
			if str(item.get("id", "")) == replacing_id:
				next.append(prepared)
			else:
				next.append(item)
		counters = next
	var trial := project.duplicate(true)
	trial["counters"] = counters
	return CounterLogic.validate_links(trial)


func elapsed_text(project: Dictionary) -> String:
	var total := _elapsed_sec(project)
	var hours := int(total / 3600)
	var minutes := int((total % 3600) / 60)
	if hours > 0:
		return "%d h %d m" % [hours, minutes]
	return "%d m" % minutes


func load_sample() -> void:
	if not OS.is_debug_build():
		return
	var list: Array = []
	for i in 5:
		var craft := "knit" if i % 2 == 0 else "crochet"
		var project := Schema.new_project("Sample %d" % (i + 1), craft)
		project["target"] = 60 if i == 0 else 0
		project["counters"][0]["value"] = i * 3
		if i == 0:
			project["notes"] = "needles\nyarn"
		if i == 4:
			project["archived"] = true
		list.append(project)
	_data["projects"] = list
	_data["active_project_id"] = list[0]["id"]
	mark_dirty()
	changed.emit(str(list[0]["id"]))


func edit_value(counter_id: String, value: int) -> void:
	var project := active_project()
	if project.is_empty():
		return
	_apply(project, CounterLogic.set_value(project, counter_id, value))


func mark_dirty() -> void:
	_dirty = true
	if _save_queued:
		return
	_save_queued = true
	call_deferred("_deferred_save")


func save_now() -> void:
	if not _dirty:
		return
	var started := Time.get_ticks_usec()
	save_to_dir(DATA_DIR, _data)
	_dirty = false
	if OS.is_debug_build():
		var ms := (Time.get_ticks_usec() - started) / 1000.0
		print("Clickety save %s in %.2f ms" % [ProjectSettings.globalize_path(_main_path(DATA_DIR)), ms])
	_push_widget()


static func load_from_dir(dir: String) -> Dictionary:
	_ensure_dir(dir)
	var main_path := _main_path(dir)
	var parsed = _read_json(main_path)
	if parsed != null:
		return Schema.validate(Schema.migrate(parsed))
	if FileAccess.file_exists(main_path):
		var rescue := dir.path_join("projects.corrupt-%d.json" % int(Time.get_unix_time_from_system()))
		var copied := DirAccess.copy_absolute(main_path, rescue)
		if copied != OK:
			push_error("Clickety could not rescue %s (%s)" % [main_path, error_string(copied)])
	var backup = _read_json(main_path + ".bak")
	if backup != null:
		return Schema.validate(Schema.migrate(backup))
	return Schema.new_file()


static func save_to_dir(dir: String, data: Dictionary) -> void:
	_ensure_dir(dir)
	var main_path := _main_path(dir)
	var tmp_path := main_path + ".tmp"
	var bak_path := main_path + ".bak"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Clickety could not open %s (%s)" % [tmp_path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	if FileAccess.file_exists(main_path) and _read_json(main_path) != null:
		if FileAccess.file_exists(bak_path):
			DirAccess.remove_absolute(bak_path)
		var copied := DirAccess.copy_absolute(main_path, bak_path)
		if copied != OK:
			push_error("Clickety could not write %s (%s)" % [bak_path, error_string(copied)])
	var renamed := DirAccess.rename_absolute(tmp_path, main_path)
	if renamed != OK:
		DirAccess.remove_absolute(main_path)
		renamed = DirAccess.rename_absolute(tmp_path, main_path)
		if renamed != OK:
			push_error("Clickety could not replace %s (%s)" % [main_path, error_string(renamed)])


static func _main_path(dir: String) -> String:
	return dir.path_join(FILE_NAME)


static func _ensure_dir(dir: String) -> void:
	var abs := ProjectSettings.globalize_path(dir)
	var err := DirAccess.make_dir_recursive_absolute(abs)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Clickety could not create %s (%s)" % [abs, error_string(err)])


static func _read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return parsed


func _mutate(counter_id: String, kind: String) -> void:
	var project := active_project()
	if project.is_empty():
		return
	var result := {}
	if kind == "minus":
		result = CounterLogic.decrement(project, counter_id)
	else:
		result = CounterLogic.increment(project, counter_id, kind)
	_apply(project, result, kind)
	if kind == "tap" or kind == "widget":
		_raise_alerts(project, result)


func _apply(project: Dictionary, result: Dictionary, _kind: String = "") -> void:
	if bool(result.get("blocked", false)):
		return
	var delta: Dictionary = result.get("changed", {})
	if delta.is_empty():
		return
	_touch(project)
	changed.emit(str(project.get("id", "")))
	var wrapped_ids: Array = result.get("wrapped", [])
	if not wrapped_ids.is_empty():
		wrapped.emit(str(project.get("id", "")), wrapped_ids)
	_maybe_refresh_reminder(delta)


func take_alert_texts() -> Array:
	var texts := _pending_alert_texts.duplicate()
	_pending_alert_texts.clear()
	return texts


func save_alert(project_id: String, alert: Dictionary) -> void:
	var project := project_by_id(project_id)
	if project.is_empty():
		return
	var cleaned := _clean_alert(alert)
	var alerts := _alert_list(project)
	var alert_id := str(cleaned.get("id", ""))
	var next: Array = []
	var found := false
	for item in alerts:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("id", "")) == alert_id:
			next.append(cleaned)
			found = true
		else:
			next.append(item)
	if not found:
		next.append(cleaned)
	project["alerts"] = next
	_touch(project)
	changed.emit(project_id)


func delete_alert(project_id: String, alert_id: String) -> void:
	var project := project_by_id(project_id)
	if project.is_empty():
		return
	var next: Array = []
	for item in _alert_list(project):
		if typeof(item) != TYPE_DICTIONARY or str(item.get("id", "")) != alert_id:
			next.append(item)
	project["alerts"] = next
	_touch(project)
	changed.emit(project_id)


func _raise_alerts(project: Dictionary, result: Dictionary) -> void:
	var hits: Array = Alerts.hits(project, result)
	if hits.is_empty():
		return
	var texts: Array = []
	for alert in hits:
		var text := str(alert.get("text", "")).strip_edges()
		if text == "":
			text = "Row alert"
		texts.append(text)
	_pending_alert_texts.append_array(texts)
	mark_dirty()
	alerted.emit(texts)


func _maybe_refresh_reminder(delta: Dictionary) -> void:
	for counter_id in delta:
		var pair = delta[counter_id]
		if typeof(pair) == TYPE_ARRAY and pair.size() >= 2 and absi(int(pair[1]) - int(pair[0])) >= 10:
			NotifyService.reschedule()
			return


func _alert_list(project: Dictionary) -> Array:
	var raw = project.get("alerts", [])
	if typeof(raw) != TYPE_ARRAY:
		return []
	return raw


func _clean_alert(alert: Dictionary) -> Dictionary:
	var kind := "every" if str(alert.get("kind", "")) == "every" else "at"
	var text := str(alert.get("text", "")).strip_edges().substr(0, 80)
	var counter_id := str(alert.get("counter_id", ""))
	var cleaned := {
		"id": str(alert.get("id", "")) if str(alert.get("id", "")) != "" else Schema.new_id(),
		"kind": kind,
		"counter_id": counter_id,
		"row": maxi(0, int(alert.get("row", 0))),
		"every": maxi(1, int(alert.get("every", 1))),
		"from": maxi(0, int(alert.get("from", 0))),
		"text": text,
		"done": bool(alert.get("done", false)) if kind == "at" else false,
	}
	return cleaned


func _touch(project: Dictionary) -> void:
	project["updated"] = int(Time.get_unix_time_from_system())
	mark_dirty()


func _deferred_save() -> void:
	_save_queued = false
	save_now()


func merge_widget_pending() -> void:
	var pending := WidgetSync.take_pending()
	if pending.is_empty():
		return
	pending.sort_custom(_pending_before)
	var applied := false
	var open_unlock := false
	for entry in pending:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if str(entry.get("route", "")) == "unlock":
			open_unlock = true
			continue
		var project_id := str(entry.get("project_id", ""))
		var counter_id := str(entry.get("counter_id", ""))
		var project := project_by_id(project_id)
		if project.is_empty() or _counter_by_id(project, counter_id).is_empty():
			if OS.is_debug_build():
				print("WidgetSync: dropped pending %s %s" % [project_id, counter_id])
			continue
		var result := CounterLogic.increment(project, counter_id, "widget")
		_apply(project, result, "widget")
		_raise_alerts(project, result)
		applied = true
	if applied:
		save_now()
	if open_unlock and not Purchase.is_unlocked():
		_open_unlock.call_deferred()


func _open_unlock() -> void:
	if Purchase.is_unlocked():
		return
	var tree := get_tree()
	if tree == null:
		return
	var current := tree.current_scene
	if current != null and current.scene_file_path == "res://scenes/unlock.tscn":
		return
	Purchase.set_intent("", "counter")
	tree.change_scene_to_file("res://scenes/unlock.tscn")


func _pending_before(a: Variant, b: Variant) -> bool:
	return _pending_time(a) < _pending_time(b)


func _pending_time(entry: Variant) -> float:
	if typeof(entry) != TYPE_DICTIONARY:
		return 0.0
	return float(entry.get("t", 0))


func _push_widget() -> void:
	WidgetSync.push_active()


func _pause_timers() -> void:
	var now := int(Time.get_unix_time_from_system())
	var changed_any := false
	for project in _data.get("projects", []):
		if typeof(project) != TYPE_DICTIONARY:
			continue
		var timer = project.get("timer", {})
		if typeof(timer) != TYPE_DICTIONARY:
			continue
		var since := int(timer.get("running_since", 0))
		if since <= 0:
			continue
		timer["total_sec"] = int(timer.get("total_sec", 0)) + maxi(0, now - since)
		timer["running_since"] = 0
		project["timer"] = timer
		changed_any = true
	if changed_any:
		mark_dirty()


func _commit_counters(project: Dictionary, counters: Array) -> Array:
	var trial := project.duplicate(true)
	trial["counters"] = counters
	var errors := CounterLogic.validate_links(trial)
	if not errors.is_empty():
		return errors
	project["counters"] = counters
	_touch(project)
	changed.emit(str(project.get("id", "")))
	return []


func _prepare_counter(counter: Dictionary, role: String, color_idx: int) -> Dictionary:
	var out: Dictionary = counter.duplicate(true)
	if str(out.get("id", "")) == "":
		out["id"] = Schema.new_id()
	out["name"] = str(out.get("name", "Counter")).substr(0, 40)
	if str(out["name"]) == "":
		out["name"] = "Counter"
	out["role"] = role if role == "main" else "extra"
	out["start"] = int(out.get("start", 0))
	out["step"] = maxi(1, int(out.get("step", 1)))
	out["reset_at"] = maxi(0, int(out.get("reset_at", 0)))
	var value := int(out.get("value", out["start"]))
	if value < int(out["start"]):
		value = int(out["start"])
	if int(out["reset_at"]) > 0 and value > int(out["reset_at"]):
		value = int(out["reset_at"])
	out["value"] = value
	out["color_idx"] = int(out.get("color_idx", color_idx))
	var link = out.get("link", {})
	if typeof(link) != TYPE_DICTIONARY or str(link.get("to", "")) == "":
		out["link"] = {}
	else:
		var on := str(link.get("on", ""))
		if on != "step" and on != "wrap":
			out["link"] = {}
		else:
			out["link"] = {"to": str(link.get("to", "")), "on": on}
	return out


func _counters_of(project: Dictionary) -> Array:
	var raw = project.get("counters", [])
	return raw.duplicate() if typeof(raw) == TYPE_ARRAY else []


func _next_color(project: Dictionary) -> int:
	var highest := -1
	for counter in _counters_of(project):
		highest = maxi(highest, int(counter.get("color_idx", 0)))
	return highest + 1


func _counter_by_id(project: Dictionary, counter_id: String) -> Dictionary:
	for counter in _counters_of(project):
		if str(counter.get("id", "")) == counter_id:
			return counter
	return {}


func _main_counter(project: Dictionary) -> Dictionary:
	for counter in _counters_of(project):
		if str(counter.get("role", "")) == "main":
			return counter
	var counters := _counters_of(project)
	return counters[0] if not counters.is_empty() else {}


func _elapsed_sec(project: Dictionary) -> int:
	var timer = project.get("timer", {})
	if typeof(timer) != TYPE_DICTIONARY:
		return 0
	var total := int(timer.get("total_sec", 0))
	var since := int(timer.get("running_since", 0))
	if since > 0:
		total += maxi(0, int(Time.get_unix_time_from_system()) - since)
	return maxi(0, total)


func _prune_deleted() -> void:
	var deleted_dir := DATA_DIR.path_join("deleted")
	var folder := DirAccess.open(deleted_dir)
	if folder == null:
		return
	var cutoff := int(Time.get_unix_time_from_system()) - 30 * 86400
	var doomed: Array[String] = []
	folder.list_dir_begin()
	var file_name := folder.get_next()
	while file_name != "":
		if not folder.current_is_dir() and file_name.ends_with(".json"):
			var stamp := _deleted_stamp(file_name)
			if stamp > 0 and stamp < cutoff:
				doomed.append(file_name)
		file_name = folder.get_next()
	folder.list_dir_end()
	for entry in doomed:
		folder.remove(entry)


func _deleted_stamp(file_name: String) -> int:
	var base := file_name.get_basename()
	var dash := base.rfind("-")
	if dash < 0:
		return 0
	var tail := base.substr(dash + 1)
	if not tail.is_valid_int():
		return 0
	return int(tail)


func _write_deleted_copy(project: Dictionary) -> void:
	var deleted_dir := DATA_DIR.path_join("deleted")
	_ensure_dir(deleted_dir)
	var path := deleted_dir.path_join("%s-%d.json" % [str(project.get("id", "project")), int(Time.get_unix_time_from_system())])
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Clickety could not archive deleted project %s" % path)
		return
	file.store_string(JSON.stringify(project))
	file.flush()
	file.close()
