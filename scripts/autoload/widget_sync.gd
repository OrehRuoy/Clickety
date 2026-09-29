extends Node

var _bridge: Object = null
var _reload_queued := false


func _ready() -> void:
	if Engine.has_singleton("WidgetBridge"):
		_bridge = Engine.get_singleton("WidgetBridge")


func available() -> bool:
	return _bridge != null and bool(_bridge.is_available())


func push(snapshot: Dictionary) -> void:
	if not available():
		print("WidgetSync: not available, skipped push")
		return
	_bridge.write_snapshot(JSON.stringify(snapshot))
	_queue_reload()


func push_test(value: int) -> void:
	var snapshot := {
		"v": 1,
		"unlocked": true,
		"project": "Spike",
		"counter": "Row",
		"value": value,
		"target": 60,
		"repeat_name": "Repeat",
		"repeat_value": 1,
		"repeat_of": 8,
		"project_id": "spike",
		"counter_id": "row",
		"updated": Time.get_unix_time_from_system(),
	}
	if not available():
		print("WidgetSync: not available, skipped push ", value)
		return
	_bridge.write_snapshot(JSON.stringify(snapshot))
	_queue_reload()


func take_pending() -> Array:
	if not available():
		print("WidgetSync: not available, pending is empty")
		return []
	var parsed: Variant = JSON.parse_string(_bridge.take_pending())
	if parsed is Array:
		return parsed
	return []


func _queue_reload() -> void:
	if _reload_queued:
		return
	_reload_queued = true
	await get_tree().create_timer(0.5).timeout
	_reload_queued = false
	if available():
		_bridge.reload()
