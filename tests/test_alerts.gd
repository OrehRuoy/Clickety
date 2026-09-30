extends Control


func _ready() -> void:
	var message := _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var counter_id := "row"
	var project := {
		"alerts": [
			{"id": "every", "kind": "every", "counter_id": counter_id, "every": 6, "from": 0, "text": "Decrease", "done": false},
			{"id": "at", "kind": "at", "counter_id": counter_id, "row": 40, "text": "Buttonhole", "done": false},
		],
	}
	var failure := ""
	for value in [0, 5, 7]:
		if not Alerts.hits(project, _up(counter_id, value - 1, value)).is_empty():
			failure = "FAIL: every hit at %d" % value
			break
	if failure == "":
		for value in [6, 12, 18]:
			var hit: Array = Alerts.hits(project, _up(counter_id, value - 1, value))
			if hit.size() != 1 or str(hit[0].get("text", "")) != "Decrease":
				failure = "FAIL: every missed %d" % value
				break
	if failure == "" and not Alerts.hits(project, _up(counter_id, 6, 5)).is_empty():
		failure = "FAIL: a decrease raised an alert"
	if failure == "":
		var once: Array = Alerts.hits(project, _up(counter_id, 39, 40))
		if once.size() != 1 or str(once[0].get("text", "")) != "Buttonhole":
			failure = "FAIL: at-row missed"
		elif not bool(project["alerts"][1].get("done", false)):
			failure = "FAIL: at-row was not marked done"
		elif not Alerts.hits(project, _up(counter_id, 39, 40)).is_empty():
			failure = "FAIL: undo then the same tap hit again"
		elif not bool(project["alerts"][1].get("done", false)):
			failure = "FAIL: done was cleared"
	return "PASS" if failure == "" else failure


func _up(counter_id: String, before: int, after: int) -> Dictionary:
	return {"changed": {counter_id: [before, after]}}
