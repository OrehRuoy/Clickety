extends Control


func _ready() -> void:
	var message := await _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var backup := _read_entitlement()
	var failure := ""
	if Purchase.message_for("Purchase cancelled.") != "":
		failure = "FAIL: cancelled purchase showed a message"
	elif Purchase.message_for("Nothing to restore.") != "No previous unlock found for this Apple ID.":
		failure = "FAIL: restore copy"
	elif Purchase.message_for("Waiting for approval.") != "Waiting for approval (Ask to Buy). It unlocks by itself once approved.":
		failure = "FAIL: approval copy"
	if failure == "":
		Purchase.set_pretend(true)
		Purchase.set_pretend(false)
		if Purchase.is_unlocked():
			failure = "FAIL: pretend off stayed unlocked"
	if failure == "":
		Purchase.buy()
		await get_tree().create_timer(1.2).timeout
		if not Purchase.is_unlocked():
			failure = "FAIL: fake buy did not unlock"
		else:
			Purchase.set_pretend(false)
			if not Purchase.is_unlocked():
				failure = "FAIL: pretend off cleared a purchase"
	_write_entitlement(backup)
	Purchase.reload_cache()
	return "PASS" if failure == "" else failure


func _read_entitlement() -> String:
	var path := "user://data/entitlement.json"
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _write_entitlement(text: String) -> void:
	var path := "user://data/entitlement.json"
	if text == "":
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.flush()
	file.close()
