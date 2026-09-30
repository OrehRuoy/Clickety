extends Control


func _ready() -> void:
	var root := "user://backup-test-%d" % Time.get_ticks_usec()
	var message := _run(root)
	_wipe(root)
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _run(root: String) -> String:
	var project := Schema.new_project("Hat", "knit")
	project["counters"][0]["value"] = 7
	var original := Schema.new_file()
	original["projects"] = [project]
	original["active_project_id"] = project["id"]
	var settings := {"theme": "night", "keep_awake": false}
	var path := Backup.write_export(root, original, settings)
	var parsed := Backup.parse_file(path)
	if not bool(parsed.get("ok", false)):
		return "FAIL: export did not parse"
	var body := JSON.stringify(Backup.payload(original, settings, "1.0.0", 1000))
	if body.contains("entitlement"):
		return "FAIL: backup included an entitlement"
	var preview := Backup.preview(parsed)
	if not preview.begins_with("1 projects, 1 counters, saved "):
		return "FAIL: preview %s" % preview
	var added := Backup.add_projects(original, parsed["projects"])
	var added_projects: Array = added.get("projects", [])
	if added_projects.size() != 2:
		return "FAIL: add did not double projects"
	if str(added_projects[0].get("id", "")) != project["id"]:
		return "FAIL: add changed the original id"
	if str(added_projects[1].get("id", "")) == project["id"]:
		return "FAIL: add kept a colliding id"
	if str(added.get("active_project_id", "")) != project["id"]:
		return "FAIL: add changed the active project"
	var replaced: Dictionary = parsed["projects"]
	var replaced_projects: Array = replaced.get("projects", [])
	if replaced_projects.size() != 1:
		return "FAIL: replace project count"
	if str(replaced_projects[0].get("id", "")) != project["id"]:
		return "FAIL: replace changed the id"
	if str(replaced_projects[0].get("name", "")) != "Hat":
		return "FAIL: replace changed the name"
	if int(replaced_projects[0]["counters"][0].get("value", 0)) != 7:
		return "FAIL: replace changed the count"
	if str(parsed["settings"].get("theme", "")) != "night":
		return "FAIL: settings were dropped"
	if Backup.parse("nope").get("error", "") != "This file isn't a Clickety backup.":
		return "FAIL: garbage was accepted"
	if bool(Backup.parse("{}").get("ok", false)):
		return "FAIL: empty object was accepted"
	var old := {
		"version": 0,
		"projects": [{"name": "Old", "counters": [{"name": "Row", "role": "main", "value": 4}]}],
	}
	var migrated := Backup.parse(JSON.stringify(Backup.payload(old, {}, "1.0.0", 1000)))
	if not bool(migrated.get("ok", false)):
		return "FAIL: old backup rejected"
	var migrated_projects: Dictionary = migrated["projects"]
	if int(migrated_projects.get("version", 0)) != 1:
		return "FAIL: old backup did not migrate"
	var old_rows: Array = migrated_projects.get("projects", [])
	if old_rows.is_empty() or str(old_rows[0].get("name", "")) != "Old":
		return "FAIL: old project name lost"
	if int(old_rows[0]["counters"][0].get("value", 0)) != 4:
		return "FAIL: old count lost"
	var listed := Backup.list_files(root)
	if listed.is_empty():
		return "FAIL: export was not listed"
	var backup_dir := root.path_join("Backups")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(backup_dir))
	for day in range(1, 9):
		var file := FileAccess.open(backup_dir.path_join("auto-2020-01-%02d.json" % day), FileAccess.WRITE)
		file.store_string("{}")
		file.close()
	Backup.prune_auto(backup_dir)
	var left := 0
	var access := DirAccess.open(backup_dir)
	for file_name in access.get_files():
		if str(file_name).begins_with("auto-"):
			left += 1
			if str(file_name) == "auto-2020-01-01.json":
				return "FAIL: oldest daily copy was kept"
	if left != 7:
		return "FAIL: kept %d daily copies" % left
	return "PASS"


func _wipe(root: String) -> void:
	_wipe_dir(root)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(root))


func _wipe_dir(dir: String) -> void:
	var abs := ProjectSettings.globalize_path(dir)
	if not DirAccess.dir_exists_absolute(abs):
		return
	var access := DirAccess.open(dir)
	if access == null:
		return
	for file_name in access.get_files():
		DirAccess.remove_absolute(dir.path_join(str(file_name)))
	for child in access.get_directories():
		_wipe_dir(dir.path_join(str(child)))
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dir.path_join(str(child))))
