extends Node

var _bridge: Object = null
var _reload_queued := false
var _reload_token := 0
var _staged: Array = []


func _ready() -> void:
	if Engine.has_singleton("WidgetBridge"):
		_bridge = Engine.get_singleton("WidgetBridge")
	Purchase.unlocked_changed.connect(_on_unlocked)


func available() -> bool:
	return _bridge != null and bool(_bridge.is_available())


func push_active() -> void:
	var project := Store.active_project()
	if project.is_empty():
		return
	_write(snapshot_for(project))


func push(snapshot: Dictionary) -> void:
	_write(snapshot)


func stage_pending(entries: Array) -> void:
	_staged = entries.duplicate(true)


func take_pending() -> Array:
	if not available():
		var pending := _staged.duplicate(true)
		_staged = []
		return pending
	var parsed: Variant = JSON.parse_string(_bridge.take_pending())
	if parsed is Array:
		return parsed
	return []


func flush_now() -> void:
	if not _reload_queued:
		return
	_reload_token += 1
	_reload_queued = false
	if available():
		_bridge.reload()


func snapshot_for(project: Dictionary) -> Dictionary:
	var main := {}
	var pattern := {}
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY:
			continue
		if main.is_empty() and str(counter.get("role", "")) == "main":
			main = counter
		elif pattern.is_empty() and int(counter.get("reset_at", 0)) > 0:
			pattern = counter
	if main.is_empty():
		for counter in project.get("counters", []):
			if typeof(counter) == TYPE_DICTIONARY:
				main = counter
				break
	var repeat_name := ""
	var repeat_value := 0
	var repeat_of := 0
	if not pattern.is_empty():
		var follower := _wrap_follower(project, str(pattern.get("id", "")))
		if follower.is_empty():
			repeat_name = str(pattern.get("name", ""))
			repeat_value = int(pattern.get("value", 0))
			repeat_of = int(pattern.get("reset_at", 0))
		else:
			repeat_name = "%s %d/%d · %s" % [
				str(pattern.get("name", "")),
				int(pattern.get("value", 0)),
				int(pattern.get("reset_at", 0)),
				str(follower.get("name", "")),
			]
			repeat_value = int(follower.get("value", 0))
	return {
		"v": 1,
		"unlocked": Purchase.is_unlocked(),
		"project": str(project.get("name", "")),
		"counter": str(main.get("name", "Row")),
		"value": int(main.get("value", 0)),
		"target": int(project.get("target", 0)),
		"repeat_name": repeat_name,
		"repeat_value": repeat_value,
		"repeat_of": repeat_of,
		"project_id": str(project.get("id", "")),
		"counter_id": str(main.get("id", "")),
		"updated": Time.get_unix_time_from_system(),
	}


func _on_unlocked(_is_on: bool) -> void:
	push_active()


func _wrap_follower(project: Dictionary, pattern_id: String) -> Dictionary:
	if pattern_id == "":
		return {}
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY:
			continue
		var link = counter.get("link", {})
		if typeof(link) != TYPE_DICTIONARY:
			continue
		if str(link.get("to", "")) == pattern_id and str(link.get("on", "")) == "wrap":
			return counter
	return {}


func _write(snapshot: Dictionary) -> void:
	if not available():
		return
	_bridge.write_snapshot(JSON.stringify(snapshot))
	_queue_reload()


func _queue_reload() -> void:
	if _reload_queued:
		return
	_reload_queued = true
	_reload_token += 1
	var token := _reload_token
	await get_tree().create_timer(0.5).timeout
	if token != _reload_token:
		return
	_reload_queued = false
	if available():
		_bridge.reload()
