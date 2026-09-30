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
	return "PASS"
