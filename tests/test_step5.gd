extends Control


func _ready() -> void:
	var message := _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var previous := str(Store.active_project().get("id", ""))
	var created := Store.create_project("Step5 test", "knit")
	var id := str(created.get("id", ""))
	var failure := ""
	if id == "":
		failure = "FAIL: no project"
	else:
		Store.set_active(id)
		var pair: Array = Store.add_repeat_pair(id, 8)
		if not pair.is_empty():
			failure = "FAIL: repeat pair %s" % str(pair)
		else:
			var row_id := _id(id, "Row")
			for _i in 16:
				Store.tap(row_id)
			failure = _expect(id, 16, 1, 2, "tap 16")
			if failure == "":
				Store.tap(row_id)
				failure = _expect(id, 17, 2, 2, "tap 17")
			if failure == "":
				Store.undo()
				failure = _expect(id, 16, 1, 2, "undo")
			if failure == "":
				Store.tap(row_id)
				for _i in 17:
					Store.minus(row_id)
				failure = _expect(id, 0, 1, 0, "minus 17")
			if failure == "":
				var added: Array = Store.add_counter(id, Schema.new_counter("Stitches", "extra"))
				if not added.is_empty():
					failure = "FAIL: stitches %s" % str(added)
			if failure == "":
				var stitch_id := _id(id, "Stitches")
				Store.set_focus(id, stitch_id)
				Store.tap(stitch_id)
				if _value(id, "Row") != 0 or _value(id, "Stitches") != 1:
					failure = "FAIL: stitches tap row %s stitches %s" % [str(_value(id, "Row")), str(_value(id, "Stitches"))]
				elif str(Store.project_by_id(id).get("focus_id", "")) != stitch_id:
					failure = "FAIL: focus not stitches"
			if failure == "":
				var pattern := _copy(id, "Pattern row")
				pattern["link"] = {"to": _id(id, "Repeats"), "on": "step"}
				var loop_errors: Array = Store.check_counter(id, pattern, str(pattern.get("id", "")))
				if not loop_errors.has("loop"):
					failure = "FAIL: loop %s" % str(loop_errors)
				elif Store.delete_counter(id, row_id):
					failure = "FAIL: main counter was deleted"
	if id != "":
		Store.delete_project(id)
	if previous != "" and previous != id:
		Store.set_active(previous)
	return "PASS" if failure == "" else failure


func _expect(project_id: String, row_value: int, pattern_value: int, repeats_value: int, label: String) -> String:
	var row := _value(project_id, "Row")
	var pattern := _value(project_id, "Pattern row")
	var repeats := _value(project_id, "Repeats")
	if row != row_value or pattern != pattern_value or repeats != repeats_value:
		return "FAIL: %s got Row %s Pattern row %s Repeats %s" % [label, str(row), str(pattern), str(repeats)]
	return ""


func _value(project_id: String, counter_name: String) -> int:
	for counter in Store.project_by_id(project_id).get("counters", []):
		if str(counter.get("name", "")) == counter_name:
			return int(counter.get("value", 0))
	return -999


func _id(project_id: String, counter_name: String) -> String:
	for counter in Store.project_by_id(project_id).get("counters", []):
		if str(counter.get("name", "")) == counter_name:
			return str(counter.get("id", ""))
	return ""


func _copy(project_id: String, counter_name: String) -> Dictionary:
	for counter in Store.project_by_id(project_id).get("counters", []):
		if str(counter.get("name", "")) == counter_name:
			return counter.duplicate(true)
	return {}
