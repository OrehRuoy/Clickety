extends Node

signal changed(project_id)
signal wrapped(project_id, counter_ids)

const DATA_DIR := "user://data"
const FILE_NAME := "projects.json"

var _data: Dictionary = {}
var _dirty := false
var _save_queued := false


func _ready() -> void:
	_data = load_from_dir(DATA_DIR)
	if OS.is_debug_build():
		print("Clickety data: ", ProjectSettings.globalize_path(DATA_DIR))
	if projects().is_empty():
		create_project("My project", "knit")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED \
			or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_now()


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
	_apply(project, result)


func _apply(project: Dictionary, result: Dictionary) -> void:
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


func _touch(project: Dictionary) -> void:
	project["updated"] = int(Time.get_unix_time_from_system())
	mark_dirty()


func _deferred_save() -> void:
	_save_queued = false
	save_now()


func _push_widget() -> void:
	if not WidgetSync.available():
		return
	var project := active_project()
	if project.is_empty():
		return
	WidgetSync.push(CounterLogic.summary(project))


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
