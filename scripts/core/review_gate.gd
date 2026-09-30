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


static func _year(unix_time: int) -> int:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	var when := Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)
	return int(when.get("year", 0))
