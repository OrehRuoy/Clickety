extends Control


func _ready() -> void:
	var message := _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var previous := str(Store.active_project().get("id", ""))
	var created := Store.create_project("Widget merge", "knit")
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
			var pattern_id := _id(id, "Pattern row")
			Store.edit_value(pattern_id, 6)
			WidgetSync.stage_pending([
				{"project_id": "missing", "counter_id": "nope", "d": 1, "t": 1},
				{"project_id": id, "counter_id": pattern_id, "d": 1, "t": 3},
				{"project_id": id, "counter_id": pattern_id, "d": 1, "t": 2},
				{"project_id": id, "counter_id": pattern_id, "d": 1, "t": 4},
			])
			Store.merge_widget_pending()
			failure = _expect(id, 0, 1, 1, "three taps")
			if failure == "":
				var snap := WidgetSync.snapshot_for(Store.project_by_id(id))
				if str(snap.get("repeat_name", "")) != "Pattern row 1/8 · Repeats":
					failure = "FAIL: repeat line %s" % str(snap.get("repeat_name", ""))
				elif int(snap.get("repeat_value", -1)) != 1 or int(snap.get("repeat_of", -1)) != 0:
					failure = "FAIL: repeat value %s of %s" % [str(snap.get("repeat_value", "")), str(snap.get("repeat_of", ""))]
				elif str(snap.get("counter_id", "")) != _id(id, "Row") or int(snap.get("value", -1)) != 0:
					failure = "FAIL: widget is not showing the main counter"
			if failure == "":
				Store.undo()
				failure = _expect(id, 0, 8, 0, "one undo")
			if failure == "":
				Store.merge_widget_pending()
				failure = _expect(id, 0, 8, 0, "second merge")
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
