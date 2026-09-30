extends Node

signal reminder_message(text: String)

const FIRST_ID := 9100
const DAY_COUNT := 14
const DENIED := "Notifications are off for Clickety in iOS Settings."

var _scheduler: NotificationScheduler
var _plugin_ready := false
var _arm_daily := false
var _message := ""


func _ready() -> void:
	_scheduler = NotificationScheduler.new()
	add_child(_scheduler)
	_scheduler.initialization_completed.connect(_on_plugin_ready)
	_scheduler.post_notifications_permission_granted.connect(_on_granted)
	_scheduler.post_notifications_permission_denied.connect(_on_denied)
	if Engine.has_singleton("NotificationSchedulerPlugin"):
		_scheduler.initialize()


func message() -> String:
	return _message


func set_daily(on: bool) -> void:
	if not on:
		_arm_daily = false
		_message = ""
		AppSettings.set_flag("daily", false)
		_cancel_daily()
		reminder_message.emit("")
		return
	if not Engine.has_singleton("NotificationSchedulerPlugin"):
		if OS.is_debug_build():
			print("NotifyService: no notification plugin, reminder not scheduled")
		return
	if not _plugin_ready:
		_arm_daily = true
		return
	if not _scheduler.has_post_notifications_permission():
		_arm_daily = true
		_scheduler.request_post_notifications_permission()
		return
	_turn_on()


func sync_from_settings() -> void:
	if not _plugin_ready:
		return
	if AppSettings.flag("daily"):
		reschedule()
	else:
		_cancel_daily()


func reschedule() -> void:
	if not AppSettings.flag("daily") or not _plugin_ready:
		return
	_cancel_daily()
	var body := _body()
	var hour := AppSettings.number("daily_hour")
	var minute := AppSettings.number("daily_minute")
	for day in DAY_COUNT:
		_schedule(FIRST_ID + day, _delay_for_day(day, hour, minute), body)


func test_soon() -> void:
	if not OS.is_debug_build():
		return
	if not _plugin_ready:
		print("NotifyService: no notification plugin, reminder not scheduled")
		return
	_schedule(9199, 60, _body())


func _turn_on() -> void:
	_arm_daily = false
	_message = ""
	AppSettings.set_flag("daily", true)
	reschedule()
	reminder_message.emit("")


func _on_plugin_ready() -> void:
	_plugin_ready = true
	if _arm_daily:
		set_daily(true)
	elif AppSettings.flag("daily"):
		reschedule()


func _on_granted(_permission_name: String) -> void:
	if _arm_daily:
		_turn_on()


func _on_denied(_permission_name: String) -> void:
	_arm_daily = false
	AppSettings.set_flag("daily", false)
	_message = DENIED
	reminder_message.emit(_message)


func _cancel_daily() -> void:
	if not _plugin_ready:
		return
	for day in DAY_COUNT:
		_scheduler.cancel(FIRST_ID + day)


func _schedule(notification_id: int, delay: int, body: String) -> void:
	var data := NotificationData.new()
	data.set_id(notification_id)
	data.set_title(AppInfo.DISPLAY_NAME)
	data.set_content(body)
	data.set_delay(maxi(delay, 1))
	_scheduler.schedule(data)


func _body() -> String:
	var project := Store.active_project()
	var project_name := str(project.get("name", "Your project"))
	if project_name == "":
		project_name = "Your project"
	return "%s is at row %d. A few rows tonight?" % [project_name, _main_value(project)]


func _main_value(project: Dictionary) -> int:
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return int(counter.get("value", 0))
	return 0


func _delay_for_day(day_index: int, hour: int, minute: int) -> int:
	var now_dict := Time.get_datetime_dict_from_system()
	var today := {
		"year": int(now_dict["year"]),
		"month": int(now_dict["month"]),
		"day": int(now_dict["day"]),
		"hour": hour,
		"minute": minute,
		"second": 0,
	}
	var first := int(Time.get_unix_time_from_datetime_dict(today))
	var now := int(Time.get_unix_time_from_system())
	if first <= now:
		first += 86400
	return maxi(first + day_index * 86400 - now, 1)
