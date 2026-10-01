extends Control

const PHONE := Vector2i(428, 926)
const IPAD := Vector2i(834, 1112)
const PAPER := Color("F3E6D4")
const INK := Color("1E1B18")
const ACCENT := Color("B4492E")
const YARN_LIGHT := Color("F6D7CC")
const BOLD := preload("res://assets/fonts/AtkinsonHyperlegible-Bold.ttf")
const REGULAR := preload("res://assets/fonts/AtkinsonHyperlegible-Regular.ttf")
const CARD_SHADER := "shader_type canvas_item; uniform float radius_px; uniform vec2 rect_size; void fragment() { vec2 p = UV * rect_size; vec2 q = abs(p - rect_size * 0.5) - rect_size * 0.5 + vec2(radius_px); float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius_px; float a = 1.0 - smoothstep(0.0, 1.25, d); vec4 tex = texture(TEXTURE, UV); COLOR = vec4(tex.rgb, tex.a * a); }"
const SHADE_SHADER := "shader_type canvas_item; render_mode blend_mix; uniform vec4 shade : source_color; uniform float radius_px; uniform vec2 rect_size; void fragment() { vec2 p = UV * rect_size; vec2 q = abs(p - rect_size * 0.5) - rect_size * 0.5 + vec2(radius_px); float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius_px; float a = (1.0 - smoothstep(0.0, 1.5, d)) * shade.a; COLOR = vec4(shade.rgb, a); }"


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
	var card_shader := Shader.new()
	card_shader.code = CARD_SHADER
	var shade_shader := Shader.new()
	shade_shader.code = SHADE_SHADER
	var layouts: Array = [
		{"window": PHONE, "slots": [{"folder": "iphone", "size": Vector2i(1284, 2778)}, {"folder": "iphone-alt", "size": Vector2i(1242, 2688)}]},
		{"window": IPAD, "slots": [{"folder": "ipad", "size": Vector2i(2064, 2752)}, {"folder": "ipad-alt", "size": Vector2i(2048, 2732)}]},
	]
	for layout in layouts:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(layout["window"])
		await get_tree().process_frame
		await get_tree().process_frame
		var shots := {}
		for frame_i in frames.size():
			var frame: Dictionary = frames[frame_i]
			var scene_path := str(frame["scene"])
			if not shots.has(scene_path):
				shots[scene_path] = await _grab(host, scene_path)
			var ui: Image = shots[scene_path]
			for slot in layout["slots"]:
				var size: Vector2i = slot["size"]
				var folder := str(slot["folder"])
				var align_bottom := str(frame["slug"]) == "06-trust"
				var full := await _compose(ui, size, frame_i, str(frame["title"]), str(frame["line"]), align_bottom, card_shader, shade_shader)
				_save(full, "res://screenshots/%s/%s.png" % [folder, frame["slug"]])
	_preview("res://screenshots/iphone", "res://screenshots/_panorama-iphone.png")
	_preview("res://screenshots/ipad", "res://screenshots/_panorama-ipad.png")
	AppInfo.SCREENSHOT_MODE = false
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
			for _pass in 3:
				await get_tree().process_frame
				var bar := scroll.get_v_scroll_bar()
				scroll.scroll_vertical = int(bar.max_value) if bar != null else 100000
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


func _compose(ui: Image, size: Vector2i, index: int, title: String, line: String, align_bottom: bool, card_shader: Shader, shade_shader: Shader) -> Image:
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.gui_disable_input = true
	var root := Control.new()
	root.position = Vector2.ZERO
	root.size = Vector2(size)
	root.clip_contents = true
	viewport.add_child(root)
	var bg := ColorRect.new()
	bg.color = PAPER
	bg.position = Vector2.ZERO
	bg.size = Vector2(size)
	root.add_child(bg)
	var yarn_width := maxf(28.0, float(size.x) * 0.07)
	var yarn := _yarn(size, index, yarn_width, ACCENT)
	root.add_child(yarn)
	var highlight := _yarn(size, index, yarn_width * 0.28, YARN_LIGHT)
	highlight.position = Vector2(0, -yarn_width * 0.22)
	root.add_child(highlight)
	var card := Rect2(float(size.x) * 0.07, float(size.y) * 0.40, float(size.x) * 0.86, float(size.y) * 0.55)
	var radius := float(size.x) * 0.055
	var shadow := ColorRect.new()
	shadow.position = card.position + Vector2(0, float(size.y) * 0.008)
	shadow.size = card.size
	shadow.material = _shade_material(shade_shader, card.size, radius)
	root.add_child(shadow)
	var shot := TextureRect.new()
	shot.texture = ImageTexture.create_from_image(_cover(ui, int(card.size.x), int(card.size.y), align_bottom))
	shot.ignore_texture_size = true
	shot.stretch_mode = TextureRect.STRETCH_SCALE
	shot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shot.position = card.position
	shot.size = card.size
	shot.material = _card_material(card_shader, card.size, radius)
	root.add_child(shot)
	_add_title(root, size, title, line)
	add_child(viewport)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	viewport.queue_free()
	if image.get_format() != Image.FORMAT_RGB8:
		image.convert(Image.FORMAT_RGB8)
	return image


func _yarn(size: Vector2i, index: int, width: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_NONE
	line.end_cap_mode = Line2D.LINE_CAP_NONE
	line.antialiased = true
	var points := PackedVector2Array()
	var x := -float(size.x) * 0.08
	var end := float(size.x) * 1.08
	while x <= end:
		var along := (float(index * size.x) + x) / float(size.x * 3)
		var y := float(size.y) * 0.325 + sin(along * TAU) * float(size.y) * 0.05
		points.append(Vector2(x, y))
		x += 12.0
	line.points = points
	return line


func _add_title(root: Control, size: Vector2i, title: String, line: String) -> void:
	var heading := Label.new()
	heading.text = title
	heading.position = Vector2(float(size.x) * 0.07, float(size.y) * 0.045)
	heading.size = Vector2(float(size.x) * 0.86, float(size.y) * 0.15)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.max_lines_visible = 2
	heading.clip_text = true
	heading.add_theme_font_override("font", BOLD)
	heading.add_theme_font_size_override("font_size", int(minf(float(size.x) * 0.05, float(size.y) * 0.034)))
	heading.add_theme_color_override("font_color", INK)
	root.add_child(heading)
	if line == "":
		return
	heading.size = Vector2(float(size.x) * 0.86, float(size.y) * 0.105)
	heading.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	var sub := Label.new()
	sub.text = line
	sub.position = Vector2(float(size.x) * 0.08, float(size.y) * 0.155)
	sub.size = Vector2(float(size.x) * 0.84, float(size.y) * 0.045)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.max_lines_visible = 1
	sub.clip_text = true
	sub.add_theme_font_override("font", REGULAR)
	sub.add_theme_font_size_override("font_size", int(float(size.x) * 0.028))
	sub.add_theme_color_override("font_color", ACCENT)
	root.add_child(sub)


func _card_material(shader: Shader, rect_size: Vector2, radius: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("radius_px", radius)
	material.set_shader_parameter("rect_size", rect_size)
	return material


func _shade_material(shader: Shader, rect_size: Vector2, radius: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("shade", Color(0.18, 0.1, 0.07, 0.16))
	material.set_shader_parameter("radius_px", radius)
	material.set_shader_parameter("rect_size", rect_size)
	return material


func _preview(folder: String, out_path: String) -> void:
	var slugs: PackedStringArray = ["01-hero.png", "02-linked.png", "04-projects.png"]
	var strips: Array[Image] = []
	var height := 640
	var width := 0
	for slug in slugs:
		var image := Image.new()
		var err := image.load(ProjectSettings.globalize_path("%s/%s" % [folder, slug]))
		if err != OK:
			return
		var next_w := int(round(float(image.get_width()) * float(height) / float(image.get_height())))
		image.resize(next_w, height, Image.INTERPOLATE_LANCZOS)
		if image.get_format() != Image.FORMAT_RGB8:
			image.convert(Image.FORMAT_RGB8)
		strips.append(image)
		width += next_w
	var sheet := Image.create(width, height, false, Image.FORMAT_RGB8)
	var x := 0
	for strip in strips:
		sheet.blit_rect(strip, Rect2i(0, 0, strip.get_width(), strip.get_height()), Vector2i(x, 0))
		x += strip.get_width()
	_save(sheet, out_path)


func _cover(source: Image, width: int, height: int, align_bottom: bool = false) -> Image:
	var copy := source.duplicate()
	if copy.get_format() != Image.FORMAT_RGB8:
		copy.convert(Image.FORMAT_RGB8)
	var scale := maxf(float(width) / float(copy.get_width()), float(height) / float(copy.get_height()))
	var next_w := maxi(width, int(ceil(float(copy.get_width()) * scale)))
	var next_h := maxi(height, int(ceil(float(copy.get_height()) * scale)))
	copy.resize(next_w, next_h, Image.INTERPOLATE_LANCZOS)
	var origin_y := maxi(0, next_h - height) if align_bottom else maxi(0, (next_h - height) / 2)
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
