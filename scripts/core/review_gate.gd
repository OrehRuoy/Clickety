class_name ReviewGate
extends RefCounted

const DAY := 86400
const INSTALL_WAIT := 3 * DAY
const REPEAT_WAIT := 60 * DAY
const YEAR_CAP := 3


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


static func enjoying_due(now: int, installed_at: int, launch_count: int, asked: bool) -> bool:
	if asked or launch_count < 3 or installed_at <= 0:
		return false
	return local_day(now) != local_day(installed_at)


static func local_day(unix_time: int) -> String:
	var when := _local(unix_time)
	return "%04d-%02d-%02d" % [int(when.get("year", 0)), int(when.get("month", 0)), int(when.get("day", 0))]


static func _year(unix_time: int) -> int:
	return int(_local(unix_time).get("year", 0))


static func _local(unix_time: int) -> Dictionary:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	return Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)
