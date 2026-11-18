class_name ReviewGate
extends RefCounted

const DAY := 86400
const INSTALL_WAIT := 3 * DAY
const REPEAT_WAIT := 60 * DAY
const YEAR_CAP := 3
const ROW_GOAL := 50


static func allowed(now: int, installed_at: int, review_last: int, review_count: int) -> bool:
	if installed_at <= 0 or now < installed_at + INSTALL_WAIT:
		return false
	var count := review_count
	if review_last > 0 and _year(review_last) != _year(now):
		count = 0
	if count >= YEAR_CAP:
		return false
	if review_last > 0 and now < review_last + REPEAT_WAIT:
		return false
	return true


static func next_count(now: int, review_last: int, review_count: int) -> int:
	if review_last <= 0 or _year(review_last) != _year(now):
		return 1
	return review_count + 1


static func enjoying_due(app_version: String, prompted_version: String, opted_out: bool, launch_count: int, rows_total: int, repeat_finished: bool) -> bool:
	if opted_out or launch_count <= 1:
		return false
	if app_version != "" and prompted_version == app_version:
		return false
	return rows_total >= ROW_GOAL or repeat_finished


static func rows_from_projects(projects: Array) -> int:
	var total := 0
	for project in projects:
		if typeof(project) != TYPE_DICTIONARY:
			continue
		total += _rows_in_project(project)
	return total


static func rows_in_change(project: Dictionary, changed: Dictionary, wrapped: Array) -> int:
	var main_id := ""
	var step := 1
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY or str(counter.get("role", "")) != "main":
			continue
		main_id = str(counter.get("id", ""))
		step = maxi(1, int(counter.get("step", 1)))
		break
	if main_id == "" or not changed.has(main_id):
		return 0
	var pair = changed[main_id]
	if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
		return 0
	if int(pair[1]) > int(pair[0]):
		return int(pair[1]) - int(pair[0])
	if wrapped.has(main_id):
		return step
	return 0


static func _rows_in_project(project: Dictionary) -> int:
	var main_id := ""
	var step := 1
	var value := 0
	var start := 0
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY or str(counter.get("role", "")) != "main":
			continue
		main_id = str(counter.get("id", ""))
		step = maxi(1, int(counter.get("step", 1)))
		value = int(counter.get("value", 0))
		start = int(counter.get("start", 0))
		break
	if main_id == "":
		return 0
	var counted := 0
	var saw := false
	for row in project.get("history", []):
		if typeof(row) != TYPE_DICTIONARY or str(row.get("c", "")) != main_id:
			continue
		var kind := str(row.get("k", ""))
		if kind != "tap" and kind != "widget":
			continue
		saw = true
		var delta := int(row.get("d", 0))
		if delta > 0:
			counted += delta
		elif delta < 0:
			counted += step
	if saw:
		return counted
	return maxi(0, value - start)


static func local_day(unix_time: int) -> String:
	var when := _local(unix_time)
	return "%04d-%02d-%02d" % [int(when.get("year", 0)), int(when.get("month", 0)), int(when.get("day", 0))]


static func _year(unix_time: int) -> int:
	return int(_local(unix_time).get("year", 0))


static func _local(unix_time: int) -> Dictionary:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	return Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)
