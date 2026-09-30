class_name HistoryFormat
extends RefCounted

const _DAYS := ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const _MONTHS := ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


static func lines(project: Dictionary, limit: int = 200) -> PackedStringArray:
	var history: Array = project.get("history", [])
	var start := maxi(0, history.size() - limit)
	var names := {}
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY:
			names[str(counter.get("id", ""))] = str(counter.get("name", "Row"))
	var order: Array[String] = []
	var groups := {}
	for index in range(start, history.size()):
		var row = history[index]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var when := _local(int(row.get("t", 0)))
		var day_key := "%04d-%02d-%02d" % [int(when.get("year", 0)), int(when.get("month", 0)), int(when.get("day", 0))]
		var counter_id := str(row.get("c", ""))
		var key := "%s|%s" % [day_key, counter_id]
		if not groups.has(key):
			var before := int(row.get("v", 0)) - int(row.get("d", 0))
			groups[key] = {
				"label": _day_label(when),
				"name": str(names.get(counter_id, "Row")),
				"start": before,
				"end": int(row.get("v", 0)),
				"delta": int(row.get("d", 0)),
			}
			order.append(key)
		else:
			groups[key]["end"] = int(row.get("v", 0))
			groups[key]["delta"] = int(groups[key]["delta"]) + int(row.get("d", 0))
	var out: PackedStringArray = []
	for key in order:
		var group: Dictionary = groups[key]
		var delta := int(group["delta"])
		var sign := "+" if delta >= 0 else ""
		out.append("%s · %s %d → %d (%s%d)" % [group["label"], group["name"], int(group["start"]), int(group["end"]), sign, delta])
	return out


static func weekday(unix_time: int) -> String:
	var when := _local(unix_time)
	return _DAYS[clampi(int(when.get("weekday", 0)), 0, 6)]


static func _local(unix_time: int) -> Dictionary:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	return Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)


static func _day_label(when: Dictionary) -> String:
	var month := clampi(int(when.get("month", 1)), 1, 12)
	var day_name: String = _DAYS[clampi(int(when.get("weekday", 0)), 0, 6)]
	return "%s %s %d" % [day_name, _MONTHS[month], int(when.get("day", 1))]
