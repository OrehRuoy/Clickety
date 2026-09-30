extends Control


func _ready() -> void:
	var message := _run()
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var main_path := "user://data/settings.json"
	var bak_path := main_path + ".bak"
	var had_main := FileAccess.file_exists(main_path)
	var had_bak := FileAccess.file_exists(bak_path)
	var main_text := _read(main_path)
	var bak_text := _read(bak_path)
	var failure := ""
	var flipped := not AppSettings.flag("keep_awake")
	AppSettings.set_flag("keep_awake", flipped)
	AppSettings.set_choice("theme", "contrast")
	AppSettings.set_choice("text_size", "huge")
	AppSettings.set_flag("swap_hands", true)
	AppSettings.reload()
	if AppSettings.flag("keep_awake") != flipped:
		failure = "FAIL: keep awake did not survive reload"
	elif AppSettings.resolved_theme() != "contrast":
		failure = "FAIL: theme did not survive reload"
	elif absf(AppSettings.text_scale() - 1.45) > 0.001:
		failure = "FAIL: text scale %s" % str(AppSettings.text_scale())
	elif not AppSettings.flag("swap_hands"):
		failure = "FAIL: swap hands did not survive reload"
	_restore(main_path, had_main, main_text)
	_restore(bak_path, had_bak, bak_text)
	AppSettings.reload()
	if failure == "" and not had_main and absf(AppSettings.text_scale() - 1.0) > 0.001:
		failure = "FAIL: default text scale was left changed"
	return "PASS" if failure == "" else failure


func _read(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _restore(path: String, had: bool, text: String) -> void:
	if not had:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(text)
	file.flush()
	file.close()
