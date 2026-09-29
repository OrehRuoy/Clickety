extends Control

@onready var _result: Label = %Result


func _ready() -> void:
	var message := _run()
	_result.text = message
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var checks: Array = [
		_check_hundred,
		_check_step_two,
		_check_decrement_blocked,
		_check_sixteen,
		_check_seventeen,
		_check_seventeen_back,
		_check_undo_after_wrap,
		_check_self_link,
		_check_loop,
		_check_caps,
	]
	for check in checks:
		var message: String = check.call()
		if message != "":
			return message
	return "PASS"


func _check_hundred() -> String:
	var project := Schema.new_project("Hundred", "knit")
	var row_id := str(project["counters"][0]["id"])
	for _i in 100:
		CounterLogic.increment(project, row_id)
	return _expect(project, row_id, 100, "100 taps")


func _check_step_two() -> String:
	var project := Schema.new_project("Step", "knit")
	var row: Dictionary = project["counters"][0]
	row["step"] = 2
	CounterLogic.increment(project, str(row["id"]))
	if int(row["value"]) != 2:
		return "FAIL: step 2 got %s" % str(row["value"])
	return ""


func _check_decrement_blocked() -> String:
	var project := Schema.new_project("Block", "knit")
	var row_id := str(project["counters"][0]["id"])
	var result: Dictionary = CounterLogic.decrement(project, row_id)
	if not bool(result.get("blocked", false)):
		return "FAIL: decrement at start was not blocked"
	if int(project["counters"][0]["value"]) != 0:
		return "FAIL: blocked decrement changed the value"
	return ""


func _check_sixteen() -> String:
	var project := _repeat_project()
	_tap_row(project, 16)
	return _expect_repeat(project, 16, 1, 2, "16 taps")


func _check_seventeen() -> String:
	var project := _repeat_project()
	_tap_row(project, 17)
	return _expect_repeat(project, 17, 2, 2, "17 taps")


func _check_seventeen_back() -> String:
	var project := _repeat_project()
	var row_id := _row_id(project)
	_tap_row(project, 17)
	for _i in 17:
		CounterLogic.decrement(project, row_id)
	return _expect_repeat(project, 0, 1, 0, "17 decrements")


func _check_undo_after_wrap() -> String:
	var project := _repeat_project()
	_tap_row(project, 8)
	CounterLogic.undo(project)
	return _expect_repeat(project, 7, 8, 0, "undo after wrap")


func _check_self_link() -> String:
	var project := Schema.new_project("Self", "knit")
	var row: Dictionary = project["counters"][0]
	row["link"] = {"to": row["id"], "on": "step"}
	var errors := CounterLogic.validate_links(project)
	if not _joined(errors).contains("self-link"):
		return "FAIL: self-link not reported (%s)" % _joined(errors)
	return ""


func _check_loop() -> String:
	var project := Schema.new_project("Loop", "knit")
	var row: Dictionary = project["counters"][0]
	var other := Schema.new_counter("Other", "extra")
	row["link"] = {"to": other["id"], "on": "step"}
	other["link"] = {"to": row["id"], "on": "step"}
	project["counters"].append(other)
	var errors := CounterLogic.validate_links(project)
	if not _joined(errors).contains("loop"):
		return "FAIL: loop not reported (%s)" % _joined(errors)
	return ""


func _check_caps() -> String:
	var project := Schema.new_project("Caps", "knit")
	var row_id := str(project["counters"][0]["id"])
	for _i in 2001:
		CounterLogic.increment(project, row_id)
	if project["history"].size() != 2000:
		return "FAIL: history size %s" % str(project["history"].size())
	if project["undo"].size() != 50:
		return "FAIL: undo size %s" % str(project["undo"].size())
	if int(project["history"].back()["v"]) != 2001:
		return "FAIL: newest history value %s" % str(project["history"].back()["v"])
	return ""


func _repeat_project() -> Dictionary:
	var project := Schema.new_project("Socks", "knit")
	var row: Dictionary = project["counters"][0]
	var pattern := Schema.new_counter("Pattern", "extra")
	pattern["start"] = 1
	pattern["value"] = 1
	pattern["reset_at"] = 8
	pattern["link"] = {"to": row["id"], "on": "step"}
	var repeat_counter := Schema.new_counter("Repeat", "extra")
	repeat_counter["link"] = {"to": pattern["id"], "on": "wrap"}
	project["counters"].append(pattern)
	project["counters"].append(repeat_counter)
	return project


func _tap_row(project: Dictionary, count: int) -> void:
	var row_id := _row_id(project)
	for _i in count:
		CounterLogic.increment(project, row_id)


func _row_id(project: Dictionary) -> String:
	return str(project["counters"][0]["id"])


func _expect(project: Dictionary, counter_id: String, value: int, label: String) -> String:
	for counter in project["counters"]:
		if str(counter["id"]) == counter_id and int(counter["value"]) != value:
			return "FAIL: %s got %s" % [label, str(counter["value"])]
	return ""


func _expect_repeat(project: Dictionary, row_value: int, pattern_value: int, repeat_value: int, label: String) -> String:
	var got := {
		"Row": _named(project, "Row"),
		"Pattern": _named(project, "Pattern"),
		"Repeat": _named(project, "Repeat"),
	}
	if got["Row"] != row_value or got["Pattern"] != pattern_value or got["Repeat"] != repeat_value:
		return "FAIL: %s got Row %s Pattern %s Repeat %s" % [label, str(got["Row"]), str(got["Pattern"]), str(got["Repeat"])]
	return ""


func _named(project: Dictionary, counter_name: String) -> int:
	for counter in project["counters"]:
		if str(counter["name"]) == counter_name:
			return int(counter["value"])
	return -999


func _joined(errors: Array) -> String:
	var parts: PackedStringArray = []
	for err in errors:
		parts.append(str(err))
	return " ".join(parts)
