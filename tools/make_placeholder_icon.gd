extends SceneTree

const CREAM := Color8(251, 246, 238)
const TERRACOTTA := Color8(180, 73, 46)


func _initialize() -> void:
	var icon := _paint(1024)
	var launch := _paint(256)
	if not _is_opaque(icon) or not _is_opaque(launch):
		push_error("Icon has a transparent pixel")
		quit(1)
		return
	var dir := ProjectSettings.globalize_path("res://assets/icon")
	DirAccess.make_dir_recursive_absolute(dir)
	var icon_err := icon.save_png(dir.path_join("icon_1024.png"))
	var launch_err := launch.save_png(dir.path_join("launch.png"))
	if icon_err != OK or launch_err != OK:
		push_error("save_png failed: %s / %s" % [error_string(icon_err), error_string(launch_err)])
		quit(1)
		return
	print("Wrote res://assets/icon/icon_1024.png")
	print("Wrote res://assets/icon/launch.png")
	quit()


func _paint(canvas: int) -> Image:
	var image := Image.create(canvas, canvas, false, Image.FORMAT_RGBA8)
	image.fill(CREAM)
	var scale := float(canvas) / 1024.0
	var ball := Vector2(340, 530) * scale
	_fill_circle(image, ball, 190.0 * scale, TERRACOTTA, canvas)
	_yarn_wraps(image, ball, 190.0 * scale, canvas)
	_stroke(image, Vector2(520, 620) * scale, Vector2(640, 740) * scale, 46.0 * scale, TERRACOTTA, canvas)
	_stroke(image, Vector2(640, 740) * scale, Vector2(780, 400) * scale, 46.0 * scale, TERRACOTTA, canvas)
	return image


func _fill_circle(image: Image, center: Vector2, radius: float, color: Color, canvas: int) -> void:
	var r2 := radius * radius
	var min_x := int(floor(center.x - radius))
	var max_x := int(ceil(center.x + radius))
	var min_y := int(floor(center.y - radius))
	var max_y := int(ceil(center.y + radius))
	for y in range(maxi(0, min_y), mini(canvas, max_y + 1)):
		for x in range(maxi(0, min_x), mini(canvas, max_x + 1)):
			var d := Vector2(x + 0.5, y + 0.5) - center
			if d.length_squared() <= r2:
				image.set_pixel(x, y, color)


func _stroke(image: Image, a: Vector2, b: Vector2, radius: float, color: Color, canvas: int) -> void:
	var ab := b - a
	var ab_len2 := ab.length_squared()
	if ab_len2 <= 0.0:
		_fill_circle(image, a, radius, color, canvas)
		return
	var r2 := radius * radius
	var min_x := int(floor(minf(a.x, b.x) - radius))
	var max_x := int(ceil(maxf(a.x, b.x) + radius))
	var min_y := int(floor(minf(a.y, b.y) - radius))
	var max_y := int(ceil(maxf(a.y, b.y) + radius))
	for y in range(maxi(0, min_y), mini(canvas, max_y + 1)):
		for x in range(maxi(0, min_x), mini(canvas, max_x + 1)):
			var p := Vector2(x + 0.5, y + 0.5)
			var t := clampf((p - a).dot(ab) / ab_len2, 0.0, 1.0)
			if p.distance_squared_to(a + ab * t) <= r2:
				image.set_pixel(x, y, color)


func _yarn_wraps(image: Image, center: Vector2, radius: float, canvas: int) -> void:
	var scale := float(canvas) / 1024.0
	var r2 := radius * radius
	var min_x := int(floor(center.x - radius))
	var max_x := int(ceil(center.x + radius))
	var min_y := int(floor(center.y - radius))
	var max_y := int(ceil(center.y + radius))
	for y in range(maxi(0, min_y), mini(canvas, max_y + 1)):
		for x in range(maxi(0, min_x), mini(canvas, max_x + 1)):
			var d := Vector2(x + 0.5, y + 0.5) - center
			if d.length_squared() > r2:
				continue
			var wave := d.y + sin(d.x * 0.035 / scale) * 16.0 * scale
			var band := absf(wave)
			if band < 12.0 * scale or absf(band - 72.0 * scale) < 9.0 * scale:
				image.set_pixel(x, y, CREAM)


func _is_opaque(image: Image) -> bool:
	var data := image.get_data()
	for i in range(3, data.size(), 4):
		if data[i] != 255:
			return false
	return true
