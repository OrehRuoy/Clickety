extends SceneTree

const SIZE := 1024
const CREAM := Color8(251, 246, 238)
const TERRACOTTA := Color8(180, 73, 46)


func _initialize() -> void:
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(CREAM)
	var ball := Vector2(390, 540)
	_fill_circle(image, ball, 210.0, TERRACOTTA)
	_yarn_wraps(image, ball, 210.0)
	_stroke(image, Vector2(600, 600), Vector2(740, 740), 50.0, TERRACOTTA)
	_stroke(image, Vector2(740, 740), Vector2(960, 380), 50.0, TERRACOTTA)
	if not _is_opaque(image):
		push_error("Icon has a transparent pixel")
		quit(1)
		return
	var dir := ProjectSettings.globalize_path("res://assets/icon")
	DirAccess.make_dir_recursive_absolute(dir)
	var err := image.save_png("res://assets/icon/icon_1024.png")
	if err != OK:
		push_error("save_png failed: %s" % error_string(err))
		quit(1)
		return
	print("Wrote res://assets/icon/icon_1024.png")
	quit()


func _fill_circle(image: Image, center: Vector2, radius: float, color: Color) -> void:
	var r2 := radius * radius
	var min_x := int(floor(center.x - radius))
	var max_x := int(ceil(center.x + radius))
	var min_y := int(floor(center.y - radius))
	var max_y := int(ceil(center.y + radius))
	for y in range(maxi(0, min_y), mini(SIZE, max_y + 1)):
		for x in range(maxi(0, min_x), mini(SIZE, max_x + 1)):
			var d := Vector2(x + 0.5, y + 0.5) - center
			if d.length_squared() <= r2:
				image.set_pixel(x, y, color)


func _stroke(image: Image, a: Vector2, b: Vector2, radius: float, color: Color) -> void:
	var ab := b - a
	var ab_len2 := ab.length_squared()
	if ab_len2 <= 0.0:
		_fill_circle(image, a, radius, color)
		return
	var r2 := radius * radius
	var min_x := int(floor(minf(a.x, b.x) - radius))
	var max_x := int(ceil(maxf(a.x, b.x) + radius))
	var min_y := int(floor(minf(a.y, b.y) - radius))
	var max_y := int(ceil(maxf(a.y, b.y) + radius))
	for y in range(maxi(0, min_y), mini(SIZE, max_y + 1)):
		for x in range(maxi(0, min_x), mini(SIZE, max_x + 1)):
			var p := Vector2(x + 0.5, y + 0.5)
			var t := clampf((p - a).dot(ab) / ab_len2, 0.0, 1.0)
			if p.distance_squared_to(a + ab * t) <= r2:
				image.set_pixel(x, y, color)


func _yarn_wraps(image: Image, center: Vector2, radius: float) -> void:
	var r2 := radius * radius
	var min_x := int(floor(center.x - radius))
	var max_x := int(ceil(center.x + radius))
	var min_y := int(floor(center.y - radius))
	var max_y := int(ceil(center.y + radius))
	for y in range(maxi(0, min_y), mini(SIZE, max_y + 1)):
		for x in range(maxi(0, min_x), mini(SIZE, max_x + 1)):
			var d := Vector2(x + 0.5, y + 0.5) - center
			if d.length_squared() > r2:
				continue
			var wave := d.y + sin(d.x * 0.035) * 16.0
			var band := absf(wave)
			if band < 12.0 or absf(band - 72.0) < 9.0:
				image.set_pixel(x, y, CREAM)


func _is_opaque(image: Image) -> bool:
	var data := image.get_data()
	for i in range(3, data.size(), 4):
		if data[i] != 255:
			return false
	return true
