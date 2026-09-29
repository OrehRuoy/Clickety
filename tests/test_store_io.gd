extends Control

@onready var _result: Label = %Result


func _ready() -> void:
	var message := _run()
	_result.text = message
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run() -> String:
	var migrated := _check_migrate()
	if migrated != "":
		return migrated
	var round_trip := _check_round_trip()
	if round_trip != "":
		return round_trip
	var rescued := _check_truncated_main()
	if rescued != "":
		return rescued
	var both_bad := _check_both_bad()
	if both_bad != "":
		return both_bad
	var protected := _check_bak_not_overwritten()
	if protected != "":
		return protected
	return "PASS"


func _check_migrate() -> String:
	var sample := {
		"nickname": "keep",
		"legacy": 3,
		"projects": [],
	}
	var migrated: Dictionary = Schema.migrate(sample)
	if int(migrated.get("version", 0)) != 1:
		return "FAIL: migrate version %s" % str(migrated.get("version"))
	if str(migrated.get("nickname", "")) != "keep" or int(migrated.get("legacy", 0)) != 3:
		return "FAIL: migrate dropped unknown keys"
	var validated: Dictionary = Schema.validate(migrated)
	if str(validated.get("nickname", "")) != "keep" or int(validated.get("legacy", 0)) != 3:
		return "FAIL: validate dropped unknown keys"
	return ""


func _check_round_trip() -> String:
	var dir := "user://_test_store_io/round"
	_prepare(dir)
	var data := Schema.new_file()
	var project := Schema.new_project("Hat", "crochet")
	project["notes"] = "wool"
	project["kept_project_key"] = "yes"
	data["projects"] = [project]
	data["active_project_id"] = project["id"]
	data["nickname"] = "keep"
	Store.save_to_dir(dir, data)
	var loaded: Dictionary = Store.load_from_dir(dir)
	if str(loaded.get("nickname", "")) != "keep":
		return "FAIL: round trip dropped nickname"
	if loaded["projects"].is_empty():
		return "FAIL: round trip lost projects"
	var got: Dictionary = loaded["projects"][0]
	if str(got.get("name", "")) != "Hat" or str(got.get("craft", "")) != "crochet":
		return "FAIL: round trip project %s / %s" % [str(got.get("name")), str(got.get("craft"))]
	if str(got.get("notes", "")) != "wool" or str(got.get("kept_project_key", "")) != "yes":
		return "FAIL: round trip dropped project fields"
	if int(got["counters"][0]["value"]) != 0 or str(got["counters"][0]["name"]) != "Row":
		return "FAIL: round trip counter changed"
	return ""


func _check_truncated_main() -> String:
	var dir := "user://_test_store_io/rescue"
	_prepare(dir)
	var good := _good_file("FromBak", 4)
	var bak_text := JSON.stringify(good)
	_write(dir.path_join("projects.json.bak"), bak_text)
	_write(dir.path_join("projects.json"), "{")
	var loaded: Dictionary = Store.load_from_dir(dir)
	if loaded["projects"].is_empty() or str(loaded["projects"][0].get("name", "")) != "FromBak":
		return "FAIL: truncated main did not load the bak"
	if int(loaded["projects"][0]["counters"][0]["value"]) != 4:
		return "FAIL: bak value changed"
	if _read(dir.path_join("projects.json.bak")) != bak_text:
		return "FAIL: loading a bad main overwrote the bak"
	if not _has_rescue(dir):
		return "FAIL: no corrupt rescue copy"
	return ""


func _check_both_bad() -> String:
	var dir := "user://_test_store_io/both"
	_prepare(dir)
	_write(dir.path_join("projects.json"), "{")
	_write(dir.path_join("projects.json.bak"), "{")
	var loaded: Dictionary = Store.load_from_dir(dir)
	if int(loaded.get("version", 0)) != 1 or not loaded.get("projects", []).is_empty():
		return "FAIL: both bad did not become a fresh file"
	if not _has_rescue(dir):
		return "FAIL: both bad wrote no rescue copy"
	return ""


func _check_bak_not_overwritten() -> String:
	var dir := "user://_test_store_io/protect"
	_prepare(dir)
	var good := _good_file("Safe", 9)
	var bak_text := JSON.stringify(good)
	_write(dir.path_join("projects.json.bak"), bak_text)
	_write(dir.path_join("projects.json"), "{not-json")
	var replacement := Schema.new_file()
	replacement["nickname"] = "new"
	Store.save_to_dir(dir, replacement)
	if _read(dir.path_join("projects.json.bak")) != bak_text:
		return "FAIL: save copied a bad main over the bak"
	var loaded: Dictionary = Store.load_from_dir(dir)
	if str(loaded.get("nickname", "")) != "new":
		return "FAIL: save did not replace the bad main (%s)" % str(loaded.get("nickname", ""))
	var started := Time.get_ticks_usec()
	Store.save_to_dir(dir, _large_file())
	var ms := (Time.get_ticks_usec() - started) / 1000.0
	print("Clickety large save %.2f ms" % ms)
	return ""


func _good_file(project_name: String, value: int) -> Dictionary:
	return {
		"version": 1,
		"active_project_id": "p1",
		"nickname": "keep",
		"projects": [{
			"id": "p1",
			"name": project_name,
			"craft": "knit",
			"created": 1,
			"updated": 1,
			"notes": "",
			"target": 0,
			"archived": false,
			"timer": {"shown": false, "running_since": 0, "total_sec": 0},
			"counters": [{
				"id": "c1",
				"name": "Row",
				"value": value,
				"start": 0,
				"step": 1,
				"reset_at": 0,
				"role": "main",
				"link": {},
				"color_idx": 0,
			}],
			"alerts": [],
			"history": [],
			"undo": [],
			"kept_project_key": "yes",
		}],
	}


func _large_file() -> Dictionary:
	var data := Schema.new_file()
	var projects: Array = []
	for i in 20:
		var project := Schema.new_project("P%d" % i, "knit")
		var history: Array = []
		var counter_id := str(project["counters"][0]["id"])
		for h in 2000:
			history.append({"t": h, "c": counter_id, "d": 1, "v": h, "k": "tap"})
		project["history"] = history
		projects.append(project)
	data["projects"] = projects
	return data


func _prepare(dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var folder := DirAccess.open(dir)
	if folder == null:
		return
	var names: Array = []
	folder.list_dir_begin()
	var file_name := folder.get_next()
	while file_name != "":
		if not folder.current_is_dir():
			names.append(file_name)
		file_name = folder.get_next()
	folder.list_dir_end()
	for entry in names:
		folder.remove(entry)


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.flush()
	file.close()


func _read(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


func _has_rescue(dir: String) -> bool:
	var folder := DirAccess.open(dir)
	if folder == null:
		return false
	folder.list_dir_begin()
	var file_name := folder.get_next()
	while file_name != "":
		if file_name.begins_with("projects.corrupt-"):
			folder.list_dir_end()
			return true
		file_name = folder.get_next()
	folder.list_dir_end()
	return false
