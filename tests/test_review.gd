extends Control


func _ready() -> void:
	var message := _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var now := 1_700_000_000
	var installed := now - 10 * 86400
	if ReviewGate.allowed(now, now - 86400, 0, 0):
		return "FAIL: asked during the first 3 days"
	if not ReviewGate.allowed(now, installed, 0, 0):
		return "FAIL: a quiet install was blocked"
	if ReviewGate.allowed(now, installed, now - 10 * 86400, 0):
		return "FAIL: asked again inside 60 days"
	if not ReviewGate.allowed(now, installed, now - 61 * 86400, 2):
		return "FAIL: a second ask in the year was blocked"
	if ReviewGate.allowed(now, installed, now - 61 * 86400, 3):
		return "FAIL: a fourth ask in the year was allowed"
	if not ReviewGate.allowed(now, installed, now - 400 * 86400, 3):
		return "FAIL: a new year did not reset the count"
	if ReviewGate.next_count(now, now - 400 * 86400, 3) != 1:
		return "FAIL: the new year did not start at 1"
	if ReviewGate.next_count(now, now - 61 * 86400, 2) != 3:
		return "FAIL: the same year did not increment"
	if ReviewGate.enjoying_due("1.0.1", "", false, 1, 80, true):
		return "FAIL: asked on the first launch"
	if ReviewGate.enjoying_due("1.0.1", "", false, 2, 49, false):
		return "FAIL: asked before 50 rows"
	if not ReviewGate.enjoying_due("1.0.1", "", false, 2, 50, false):
		return "FAIL: 50 rows did not qualify"
	if not ReviewGate.enjoying_due("1.0.1", "", false, 2, 0, true):
		return "FAIL: a finished repeat did not qualify"
	if ReviewGate.enjoying_due("1.0.1", "1.0.1", false, 4, 80, true):
		return "FAIL: asked twice in one version"
	if not ReviewGate.enjoying_due("1.0.1", "1.0.0", false, 4, 80, false):
		return "FAIL: a new version was blocked"
	if ReviewGate.enjoying_due("1.0.1", "", true, 4, 90, true):
		return "FAIL: opt-out was ignored"
	var project := {
		"counters": [{"id": "m", "role": "main", "value": 0, "start": 0, "step": 1, "reset_at": 2}],
		"history": [
			{"c": "m", "d": 1, "k": "tap"},
			{"c": "m", "d": 1, "k": "tap"},
			{"c": "m", "d": -2, "k": "tap"},
		],
	}
	if ReviewGate.rows_from_projects([project]) != 3:
		return "FAIL: a wrap was not counted as a row"
	if ReviewGate.rows_in_change(project, {"m": [2, 0]}, ["m"]) != 1:
		return "FAIL: the wrapping tap did not count"
	if ReviewGate.rows_in_change(project, {"m": [1, 2]}, []) != 1:
		return "FAIL: a plain tap did not count"
	var bare := {"counters": [{"id": "m", "role": "main", "value": 12, "start": 0, "step": 1}], "history": []}
	if ReviewGate.rows_from_projects([bare]) != 12:
		return "FAIL: a counter with no history ignored its value"
	if AppInfo.APP_STORE_ID != "6817437890":
		return "FAIL: app store id"
	if AppInfo.WRITE_REVIEW_URL != "https://apps.apple.com/app/id6817437890?action=write-review":
		return "FAIL: write-review url"
	if AppInfo.SEWLENS_NAME != "SewLens" or AppInfo.SEWLENS_LINE != "Turn photos into sewing patterns":
		return "FAIL: SewLens copy"
	if AppInfo.SEWLENS_URL != "https://apps.apple.com/app/id6830324321":
		return "FAIL: SewLens url"
	if "AI" in AppInfo.SEWLENS_NAME or "AI" in AppInfo.SEWLENS_LINE:
		return "FAIL: SewLens copy says AI"
	var links := _settings_links()
	if links != "":
		return links
	if OS.is_debug_build():
		print("Clickety review: threshold met rows=50 repeat=no launch=2 version=1.0.1")
		print("Clickety settings: open %s" % AppInfo.DEVELOPER_URL)
		print("Clickety settings: open %s" % AppInfo.SEWLENS_URL)
	return "PASS"


func _settings_links() -> String:
	var settings := (load("res://scenes/settings.tscn") as PackedScene).instantiate()
	add_child(settings)
	var developer := ""
	var sewlens := ""
	var saw_name := false
	var saw_line := false
	for button in settings.find_children("*", "Button", true, false):
		if button.text == "More from the developer":
			developer = str(button.get_meta("store_url", ""))
		elif str(button.get_meta("store_url", "")) == AppInfo.SEWLENS_URL:
			sewlens = AppInfo.SEWLENS_URL
	for label in settings.find_children("*", "Label", true, false):
		if label.text == AppInfo.SEWLENS_NAME:
			saw_name = true
		elif label.text == AppInfo.SEWLENS_LINE:
			saw_line = true
	settings.queue_free()
	if developer != AppInfo.DEVELOPER_URL:
		return "FAIL: developer row %s" % developer
	if sewlens != AppInfo.SEWLENS_URL:
		return "FAIL: SewLens card url"
	if not saw_name or not saw_line:
		return "FAIL: SewLens card copy"
	return ""
