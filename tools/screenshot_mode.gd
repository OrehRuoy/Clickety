extends Control

const PHONE := Vector2i(428, 926)
const IPAD := Vector2i(834, 1112)
const CREAM := Color("FBF6EE")
const INK := Color("1E1B18")
const MUTED := Color("5E564E")


func _ready() -> void:
	if not OS.is_debug_build() or DisplayServer.get_name() == "headless":
		push_error("Screenshot mode needs a debug window")
		get_tree().quit(1)
		return
	await _run()


func _run() -> void:
	var projects_path := "user://data/projects.json"
	var had_projects := FileAccess.file_exists(projects_path)
	var projects_text := _read_text(projects_path)
	var settings_snapshot: Dictionary = AppSettings.snapshot()
	var exports_before := _json_names("user://Exports")
	AppInfo.SCREENSHOT_MODE = true
	AppSettings.set_choice("theme", "warm")
	AppSettings.set_choice("text_size", "default")
	AppSettings.set_flag("reduce_motion", true)
	var demo := Backup.parse(JSON.stringify(_demo_file()))
	if not bool(demo.get("ok", false)):
		push_error("Demo data was rejected")
		_restore(had_projects, projects_text, settings_snapshot, exports_before)
		get_tree().quit(1)
		return
	Store.apply_restore(demo, "replace")
	var host := Control.new()
	host.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(host)
	var frames: Array = [
		{"slug": "01-hero", "scene": "res://scenes/counter.tscn", "title": "Tap anywhere to count", "line": "No ads · No account · No subscription"},
		{"slug": "02-linked", "scene": "res://scenes/counter.tscn", "title": "Row, pattern repeat and repeats — in one tap", "line": ""},
		{"slug": "04-projects", "scene": "res://scenes/projects.tscn", "title": "Every project keeps its own count and notes", "line": ""},
		{"slug": "05-unlock", "scene": "res://scenes/unlock.tscn", "title": "Unlock once. Yours for good.", "line": ""},
		{"slug": "06-trust", "scene": "res://scenes/settings.tscn", "title": "Screen stays awake · Saves every tap · Back up to Files", "line": ""},
	]
	var layouts: Array = [
		{"window": PHONE, "slots": [Vector2i(1290, 2796), Vector2i(1284, 2778)]},
		{"window": IPAD, "slots": [Vector2i(2064, 2752)]},
	]
	for layout in layouts:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(layout["window"])
		await get_tree().process_frame
		await get_tree().process_frame
		var shots := {}
		for frame in frames:
			var scene_path := str(frame["scene"])
			if not shots.has(scene_path):
				shots[scene_path] = await _grab(host, scene_path)
			var ui: Image = shots[scene_path]
			for slot in layout["slots"]:
				var size: Vector2i = slot
				var folder := "%dx%d" % [size.x, size.y]
				var band := int(round(float(size.y) * 0.18))
				var caption := await _caption(size.x, band, str(frame["title"]), str(frame["line"]))
				var top_inset := 58 if str(frame["slug"]) == "06-trust" else -1
				var below := _cover(ui, size.x, size.y - band, top_inset)
				var full := Image.create(size.x, size.y, false, Image.FORMAT_RGB8)
				full.fill(CREAM)
				full.blit_rect(caption, Rect2i(0, 0, caption.get_width(), caption.get_height()), Vector2i(0, 0))
				full.blit_rect(below, Rect2i(0, 0, below.get_width(), below.get_height()), Vector2i(0, band))
				_save(full, "res://screenshots/%s/%s.png" % [folder, frame["slug"]])
				_save(_cover(ui, size.x, size.y, top_inset), "res://screenshots/no-captions/%s/%s.png" % [folder, frame["slug"]])
	AppInfo.SCREENSHOT_MODE = false
	DisplayServer.window_set_size(PHONE)
	await get_tree().process_frame
	var review: Image = await _grab(host, "res://scenes/unlock.tscn")
	_save(_cover(review, 1290, 2796), "res://screenshots/iap-review.png")
	_restore(had_projects, projects_text, settings_snapshot, exports_before)
	get_tree().quit(0)


func _grab(host: Control, scene_path: String) -> Image:
	for child in host.get_children():
		host.remove_child(child)
		child.free()
	var scene := (load(scene_path) as PackedScene).instantiate()
	if scene is Control:
		(scene as Control).set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(scene)
	for _i in 4:
		await get_tree().process_frame
	if scene_path.ends_with("settings.tscn"):
		var scroll := scene.find_child("Scroll", true, false) as ScrollContainer
		if scroll != null:
			scroll.scroll_vertical = 100000
			await get_tree().process_frame
			await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


func _caption(width: int, height: int, title: String, line: String) -> Image:
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.size = Vector2i(width, height)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.gui_disable_input = true
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(root)
	var bg := ColorRect.new()
	bg.color = CREAM
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var box := VBoxContainer.new()
	box.anchor_left = 0.08
	box.anchor_right = 0.92
	box.anchor_bottom = 1.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	root.add_child(box)
	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_override("font", load("res://assets/fonts/AtkinsonHyperlegible-Bold.ttf"))
	heading.add_theme_font_size_override("font_size", maxi(48, int(width * 0.046)))
	heading.add_theme_color_override("font_color", INK)
	box.add_child(heading)
	if line != "":
		var sub := Label.new()
		sub.text = line
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.add_theme_font_override("font", load("res://assets/fonts/AtkinsonHyperlegible-Regular.ttf"))
		sub.add_theme_font_size_override("font_size", maxi(28, int(width * 0.028)))
		sub.add_theme_color_override("font_color", MUTED)
		box.add_child(sub)
	add_child(viewport)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	viewport.queue_free()
	if image.get_format() != Image.FORMAT_RGB8:
		image.convert(Image.FORMAT_RGB8)
	return image


func _cover(source: Image, width: int, height: int, top_inset: int = -1) -> Image:
	var copy := source.duplicate()
	if copy.get_format() != Image.FORMAT_RGB8:
		copy.convert(Image.FORMAT_RGB8)
	var scale := maxf(float(width) / float(copy.get_width()), float(height) / float(copy.get_height()))
	var next_w := maxi(width, int(ceil(float(copy.get_width()) * scale)))
	var next_h := maxi(height, int(ceil(float(copy.get_height()) * scale)))
	copy.resize(next_w, next_h, Image.INTERPOLATE_LANCZOS)
	var origin_y := maxi(0, (next_h - height) / 2)
	if top_inset >= 0:
		origin_y = mini(maxi(0, int(round(float(top_inset) * scale))), maxi(0, next_h - height))
	var origin := Vector2i(maxi(0, (next_w - width) / 2), origin_y)
	return copy.get_region(Rect2i(origin, Vector2i(width, height)))


func _save(image: Image, resource_path: String) -> void:
	var rgb := image.duplicate()
	if rgb.get_format() != Image.FORMAT_RGB8:
		rgb.convert(Image.FORMAT_RGB8)
	var absolute := ProjectSettings.globalize_path(resource_path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var err: Error = rgb.save_png(absolute)
	if err != OK:
		push_error("Could not write %s (%s)" % [resource_path, error_string(err)])
		return
	print("%s %dx%d no-alpha" % [resource_path, rgb.get_width(), rgb.get_height()])


func _demo_file() -> Dictionary:
	var socks := Schema.new_project("Holiday socks", "knit")
	socks["target"] = 60
	socks["notes"] = "US 1.5 needles · 64 sts · Fingering, dye lot 22B"
	socks["counters"][0]["value"] = 42
	var pattern := Schema.new_counter("Pattern row", "extra")
	pattern["start"] = 1
	pattern["value"] = 3
	pattern["reset_at"] = 8
	pattern["link"] = {"to": str(socks["counters"][0]["id"]), "on": "step"}
	pattern["color_idx"] = 1
	var repeats := Schema.new_counter("Repeats", "extra")
	repeats["value"] = 5
	repeats["link"] = {"to": str(pattern["id"]), "on": "wrap"}
	repeats["color_idx"] = 2
	socks["counters"] = [socks["counters"][0], pattern, repeats]
	var bee := Schema.new_project("Amigurumi bee", "crochet")
	bee["counters"][0]["name"] = "Round"
	bee["counters"][0]["value"] = 12
	var squares := Schema.new_project("Blanket squares", "crochet")
	squares["target"] = 20
	squares["counters"][0]["value"] = 7
	var file := Schema.new_file()
	file["projects"] = [socks, bee, squares]
	file["active_project_id"] = socks["id"]
	file["hints"] = {"tap": true}
	return file


func _restore(had_projects: bool, projects_text: String, settings_snapshot: Dictionary, exports_before: PackedStringArray) -> void:
	if had_projects and projects_text != "":
		var parsed := Backup.parse(projects_text)
		if bool(parsed.get("ok", false)):
			Store.apply_restore(parsed, "replace")
	AppSettings.apply_snapshot(settings_snapshot)
	for file_name in _json_names("user://Exports"):
		if not exports_before.has(file_name):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://Exports".path_join(file_name)))


func _json_names(dir: String) -> PackedStringArray:
	var names := PackedStringArray()
	var access := DirAccess.open(dir)
	if access == null:
		return names
	for file_name in access.get_files():
		if str(file_name).ends_with(".json"):
			names.append(str(file_name))
	return names


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text
