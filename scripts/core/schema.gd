class_name Schema
extends RefCounted

const CURRENT_VERSION := 1
const HISTORY_CAP := 2000
const UNDO_CAP := 50


static func new_file() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"active_project_id": "",
		"projects": [],
	}


static func new_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return "%08x%08x" % [rng.randi() & 0x7FFFFFFF, rng.randi() & 0x7FFFFFFF]


static func new_counter(counter_name: String, role: String) -> Dictionary:
	var use_role := role if role == "main" or role == "extra" else "extra"
	return {
		"id": new_id(),
		"name": counter_name,
		"value": 0,
		"start": 0,
		"step": 1,
		"reset_at": 0,
		"role": use_role,
		"link": {},
		"color_idx": 0,
	}


static func new_project(project_name: String, craft: String) -> Dictionary:
	var use_craft := craft if craft == "knit" or craft == "crochet" else "knit"
	var now := int(Time.get_unix_time_from_system())
	return {
		"id": new_id(),
		"name": project_name,
		"craft": use_craft,
		"created": now,
		"updated": now,
		"notes": "",
		"target": 0,
		"archived": false,
		"timer": {"shown": false, "running_since": 0, "total_sec": 0},
		"counters": [new_counter("Row", "main")],
		"alerts": [],
		"history": [],
		"undo": [],
	}


static func migrate(data: Dictionary) -> Dictionary:
	var out: Dictionary = data.duplicate(true)
	var ver = out.get("version", 0)
	if not _is_number(ver) or int(ver) < CURRENT_VERSION:
		out["version"] = CURRENT_VERSION
	return out


static func validate(data: Dictionary) -> Dictionary:
	var out: Dictionary = data.duplicate(true)
	out["version"] = CURRENT_VERSION
	if not out.has("active_project_id") or typeof(out["active_project_id"]) != TYPE_STRING:
		if out.has("active_project_id"):
			_stash(out, "active_project_id", out["active_project_id"])
		out["active_project_id"] = ""
	var raw_projects = out.get("projects", [])
	if typeof(raw_projects) != TYPE_ARRAY:
		_stash(out, "projects", raw_projects)
		raw_projects = []
	var projects: Array = []
	for item in raw_projects:
		if typeof(item) != TYPE_DICTIONARY:
			_stash_list(out, "projects", item)
			continue
		projects.append(_validate_project(item))
	out["projects"] = projects
	return out


static func _validate_project(project: Dictionary) -> Dictionary:
	var out: Dictionary = project.duplicate(true)
	_coerce_string(out, "id", new_id())
	_coerce_string(out, "name", "Project")
	if not out.has("craft") or typeof(out["craft"]) != TYPE_STRING or (out["craft"] != "knit" and out["craft"] != "crochet"):
		if out.has("craft"):
			_stash(out, "craft", out["craft"])
		out["craft"] = "knit"
	_coerce_int(out, "created", 0)
	_coerce_int(out, "updated", 0)
	_coerce_string(out, "notes", "")
	_coerce_int(out, "target", 0)
	if int(out["target"]) < 0:
		_stash(out, "target", out["target"])
		out["target"] = 0
	if not out.has("archived") or typeof(out["archived"]) != TYPE_BOOL:
		if out.has("archived"):
			_stash(out, "archived", out["archived"])
		out["archived"] = false
	out["timer"] = _validate_timer(out)
	out["counters"] = _validate_counters(out)
	if not out.has("alerts") or typeof(out["alerts"]) != TYPE_ARRAY:
		if out.has("alerts"):
			_stash(out, "alerts", out["alerts"])
		out["alerts"] = []
	out["history"] = _validate_rows(out, "history", HISTORY_CAP)
	out["undo"] = _validate_rows(out, "undo", UNDO_CAP)
	return out


static func _validate_timer(project: Dictionary) -> Dictionary:
	var raw = project.get("timer", {})
	if typeof(raw) != TYPE_DICTIONARY:
		_stash(project, "timer", raw)
		raw = {}
	var timer: Dictionary = raw.duplicate(true)
	if not timer.has("shown") or typeof(timer["shown"]) != TYPE_BOOL:
		if timer.has("shown"):
			_stash(timer, "shown", timer["shown"])
		timer["shown"] = false
	_coerce_int(timer, "running_since", 0)
	_coerce_int(timer, "total_sec", 0)
	if int(timer["running_since"]) < 0:
		timer["running_since"] = 0
	if int(timer["total_sec"]) < 0:
		timer["total_sec"] = 0
	return timer


static func _validate_counters(project: Dictionary) -> Array:
	var raw = project.get("counters", [])
	if typeof(raw) != TYPE_ARRAY:
		_stash(project, "counters", raw)
		return []
	var counters: Array = []
	for item in raw:
		if typeof(item) != TYPE_DICTIONARY:
			_stash_list(project, "counters", item)
			continue
		counters.append(_validate_counter(item))
	return counters


static func _validate_counter(counter: Dictionary) -> Dictionary:
	var out: Dictionary = counter.duplicate(true)
	_coerce_string(out, "id", new_id())
	_coerce_string(out, "name", "Counter")
	_coerce_int(out, "value", 0)
	_coerce_int(out, "start", 0)
	_coerce_int(out, "step", 1)
	_coerce_int(out, "reset_at", 0)
	_coerce_int(out, "color_idx", 0)
	if int(out["step"]) < 1:
		_stash(out, "step", out["step"])
		out["step"] = 1
	if int(out["reset_at"]) < 0:
		_stash(out, "reset_at", out["reset_at"])
		out["reset_at"] = 0
	if int(out["color_idx"]) < 0:
		out["color_idx"] = 0
	var start := int(out["start"])
	var value := int(out["value"])
	var reset_at := int(out["reset_at"])
	if value < start:
		out["value"] = start
	elif reset_at > 0 and value > reset_at:
		out["value"] = reset_at
	var role := str(out.get("role", "extra"))
	if role != "main" and role != "extra":
		_stash(out, "role", out.get("role"))
		out["role"] = "extra"
	else:
		out["role"] = role
	var link = out.get("link", {})
	if typeof(link) != TYPE_DICTIONARY:
		_stash(out, "link", link)
		out["link"] = {}
	elif link.is_empty():
		out["link"] = {}
	else:
		var on := str(link.get("on", ""))
		var to = link.get("to", "")
		if typeof(to) != TYPE_STRING or (on != "step" and on != "wrap"):
			_stash(out, "link", link.duplicate(true))
			out["link"] = {}
		else:
			out["link"] = {"to": to, "on": on}
	return out


static func _validate_rows(project: Dictionary, key: String, cap: int) -> Array:
	var raw = project.get(key, [])
	if typeof(raw) != TYPE_ARRAY:
		_stash(project, key, raw)
		return []
	var rows: Array = []
	for item in raw:
		if typeof(item) != TYPE_DICTIONARY:
			_stash_list(project, key, item)
			continue
		rows.append(item)
	if rows.size() > cap:
		rows = rows.slice(rows.size() - cap)
	return rows


static func _coerce_string(data: Dictionary, key: String, fallback: String) -> void:
	if not data.has(key):
		data[key] = fallback
		return
	if typeof(data[key]) != TYPE_STRING:
		_stash(data, key, data[key])
		data[key] = fallback


static func _coerce_int(data: Dictionary, key: String, fallback: int) -> void:
	if not data.has(key):
		data[key] = fallback
		return
	if not _is_number(data[key]):
		_stash(data, key, data[key])
		data[key] = fallback
		return
	data[key] = int(data[key])


static func _stash(data: Dictionary, key: String, value: Variant) -> void:
	if typeof(data.get("_unknown")) != TYPE_DICTIONARY:
		data["_unknown"] = {}
	data["_unknown"][key] = value


static func _stash_list(data: Dictionary, key: String, value: Variant) -> void:
	if typeof(data.get("_unknown")) != TYPE_DICTIONARY:
		data["_unknown"] = {}
	if typeof(data["_unknown"].get(key)) != TYPE_ARRAY:
		data["_unknown"][key] = []
	data["_unknown"][key].append(value)


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
