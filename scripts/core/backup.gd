class_name Backup
extends RefCounted

const KIND := "clickety-backup"
const BAD := "This file isn't a Clickety backup."
const _MONTHS := ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


static func payload(projects: Dictionary, settings: Dictionary, app_version: String, created: int) -> Dictionary:
	return {
		"kind": KIND,
		"version": 1,
		"app_version": app_version,
		"created": created,
		"projects": projects,
		"settings": settings,
	}


static func parse(text: String) -> Dictionary:
	var trimmed := text.strip_edges()
	if not trimmed.begins_with("{") and not trimmed.begins_with("["):
		return _bad()
	var parsed = JSON.parse_string(trimmed)
	if typeof(parsed) != TYPE_DICTIONARY:
		return _bad()
	if str(parsed.get("kind", "")) == KIND:
		if typeof(parsed.get("projects")) != TYPE_DICTIONARY:
			return _bad()
		return {
			"ok": true,
			"error": "",
			"projects": Schema.validate(Schema.migrate(parsed["projects"])),
			"settings": parsed["settings"] if typeof(parsed.get("settings")) == TYPE_DICTIONARY else {},
			"created": int(parsed.get("created", 0)),
			"apply_settings": true,
		}
	if typeof(parsed.get("projects")) == TYPE_ARRAY:
		return {
			"ok": true,
			"error": "",
			"projects": Schema.validate(Schema.migrate(parsed)),
			"settings": {},
			"created": int(parsed.get("created", 0)),
			"apply_settings": false,
		}
	return _bad()


static func parse_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _bad()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _bad()
	var text := file.get_as_text()
	file.close()
	var parsed := parse(text)
	if bool(parsed.get("ok", false)) and int(parsed.get("created", 0)) <= 0:
		parsed["created"] = int(FileAccess.get_modified_time(path))
	return parsed


static func preview(parsed: Dictionary) -> String:
	var projects: Dictionary = parsed.get("projects", {})
	var list: Array = projects.get("projects", [])
	var counters := 0
	for project in list:
		if typeof(project) == TYPE_DICTIONARY:
			var rows = project.get("counters", [])
			if typeof(rows) == TYPE_ARRAY:
				counters += rows.size()
	return "%d projects, %d counters, saved %s" % [list.size(), counters, _saved_day(int(parsed.get("created", 0)))]


static func row_label(parsed: Dictionary, file_name: String) -> String:
	if not bool(parsed.get("ok", false)):
		return "%s · Not a Clickety backup" % file_name
	var projects: Dictionary = parsed.get("projects", {})
	var list: Array = projects.get("projects", [])
	return "%s · %d projects" % [_saved_day(int(parsed.get("created", 0))), list.size()]


static func add_projects(current: Dictionary, incoming: Dictionary) -> Dictionary:
	var out: Dictionary = current.duplicate(true)
	var seen := {}
	var projects: Array = out.get("projects", [])
	if typeof(projects) != TYPE_ARRAY:
		projects = []
	for project in projects:
		if typeof(project) == TYPE_DICTIONARY:
			seen[str(project.get("id", ""))] = true
	for project in incoming.get("projects", []):
		if typeof(project) != TYPE_DICTIONARY:
			continue
		var copy: Dictionary = project.duplicate(true)
		var project_id := str(copy.get("id", ""))
		if project_id == "" or seen.has(project_id):
			project_id = Schema.new_id()
			copy["id"] = project_id
		seen[project_id] = true
		projects.append(copy)
	out["projects"] = projects
	return out


static func write_export(root: String, projects: Dictionary, settings: Dictionary) -> String:
	var now := int(Time.get_unix_time_from_system())
	var when := _local(now)
	var stamp := "%04d-%02d-%02d-%02d%02d" % [
		int(when.get("year", 0)),
		int(when.get("month", 0)),
		int(when.get("day", 0)),
		int(when.get("hour", 0)),
		int(when.get("minute", 0)),
	]
	var dir := root.path_join("Exports")
	_ensure(dir)
	var path := dir.path_join("clickety-backup-%s.json" % stamp)
	var extra := 2
	while FileAccess.file_exists(path):
		path = dir.path_join("clickety-backup-%s-%d.json" % [stamp, extra])
		extra += 1
	_write_json(path, payload(projects, settings, str(ProjectSettings.get_setting("application/config/version")), now))
	return path


static func write_safety(root: String, projects: Dictionary, settings: Dictionary) -> String:
	var dir := root.path_join("Exports")
	_ensure(dir)
	var path := dir.path_join("clickety-before-restore-%d.json" % int(Time.get_unix_time_from_system()))
	_write_json(path, payload(projects, settings, str(ProjectSettings.get_setting("application/config/version")), int(Time.get_unix_time_from_system())))
	return path


static func keep_daily(root: String, projects: Dictionary) -> void:
	var when := _local(int(Time.get_unix_time_from_system()))
	var day := "%04d-%02d-%02d" % [int(when.get("year", 0)), int(when.get("month", 0)), int(when.get("day", 0))]
	var dir := root.path_join("Backups")
	_ensure(dir)
	var path := dir.path_join("auto-%s.json" % day)
	if not FileAccess.file_exists(path):
		_write_json(path, projects)
	prune_auto(dir)


static func prune_auto(dir: String) -> void:
	var names := _json_names(dir)
	var autos: Array[String] = []
	for file_name in names:
		if file_name.begins_with("auto-") and file_name.ends_with(".json"):
			autos.append(file_name)
	autos.sort()
	while autos.size() > 7:
		var oldest: String = autos[0]
		autos.remove_at(0)
		DirAccess.remove_absolute(dir.path_join(oldest))


static func list_files(root: String) -> Array:
	var found: Array = []
	_collect(root, found)
	_collect(root.path_join("Exports"), found)
	_collect(root.path_join("Backups"), found)
	found.sort_custom(_newer)
	return found


static func _newer(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("modified", 0)) > int(b.get("modified", 0))


static func _collect(dir: String, found: Array) -> void:
	for file_name in _json_names(dir):
		var path := dir.path_join(file_name)
		if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
			continue
		var parsed := parse_file(path)
		found.append({
			"path": path,
			"name": file_name,
			"modified": int(FileAccess.get_modified_time(path)),
			"label": row_label(parsed, file_name),
			"ok": bool(parsed.get("ok", false)),
		})


static func _json_names(dir: String) -> PackedStringArray:
	var abs := ProjectSettings.globalize_path(dir)
	if not DirAccess.dir_exists_absolute(abs):
		return PackedStringArray()
	var access := DirAccess.open(dir)
	if access == null:
		return PackedStringArray()
	var names := PackedStringArray()
	for file_name in access.get_files():
		if file_name.ends_with(".json"):
			names.append(file_name)
	return names


static func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Clickety could not open %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()


static func _ensure(dir: String) -> void:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Clickety could not create %s (%s)" % [dir, error_string(err)])


static func _bad() -> Dictionary:
	return {"ok": false, "error": BAD, "projects": {}, "settings": {}, "created": 0, "apply_settings": false}


static func _saved_day(unix_time: int) -> String:
	if unix_time <= 0:
		return "an unknown date"
	var when := _local(unix_time)
	var month := clampi(int(when.get("month", 1)), 1, 12)
	return "%s %d" % [_MONTHS[month], int(when.get("day", 1))]


static func _local(unix_time: int) -> Dictionary:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	return Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)
