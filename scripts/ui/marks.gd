class_name Mark
extends Control

@export var kind := "sun"
var locked := false


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


static func icon(kind: String, tint: Color, side: float) -> Control:
	var texture: Texture2D = load("res://assets/marks/%s.png" % kind) as Texture2D
	if texture == null:
		var drawn := Mark.new()
		drawn.kind = "hook" if kind == "hook" else "needles"
		drawn.custom_minimum_size = Vector2(side, side)
		drawn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return drawn
	var rect := TextureRect.new()
	rect.texture = texture
	rect.modulate = tint
	rect.custom_minimum_size = Vector2(side, side)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return rect


static var _wordmark_base: Image
static var _wordmark_cache := {}


static func wordmark(width: float, height: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(width, height)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.accessibility_name = AppInfo.DISPLAY_NAME
	refresh_wordmark(rect)
	return rect


static func refresh_wordmark(rect: TextureRect) -> void:
	rect.texture = _colored_wordmark()
	rect.modulate = Color.WHITE


static func _colored_wordmark() -> Texture2D:
	var palette := Palette.current()
	var ink: Color = palette["ink"]
	var accent: Color = palette["accent"]
	var key := "%s|%s" % [ink.to_html(false), accent.to_html(false)]
	if _wordmark_cache.has(key):
		return _wordmark_cache[key]
	if _wordmark_base == null:
		var source := load("res://assets/marks/wordmark.png") as Texture2D
		_wordmark_base = source.get_image()
	var image := _wordmark_base.duplicate()
	for y in image.get_height():
		for x in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a < 0.04:
				continue
			var next: Color = accent if pixel.r > pixel.g + 0.12 and pixel.r > pixel.b + 0.12 else ink
			next.a = pixel.a
			image.set_pixel(x, y, next)
	var texture := ImageTexture.create_from_image(image)
	_wordmark_cache[key] = texture
	return texture


static func show_lock(button: Button, show: bool, is_locked: bool = true) -> void:
	var existing := button.get_node_or_null("LockMark") as Mark
	if not show:
		if existing != null:
			existing.queue_free()
		return
	var mark := existing
	if mark == null:
		mark = Mark.new()
		mark.name = "LockMark"
		mark.kind = "lock"
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mark.custom_minimum_size = Vector2(22, 22)
		mark.size = Vector2(22, 22)
		button.add_child(mark)
	mark.locked = is_locked
	mark.position = Vector2(16, 17)
	mark.queue_redraw()


func _draw() -> void:
	if kind == "minus":
		_draw_minus()
		return
	var palette := Palette.current()
	var file := kind
	var tint: Color = palette["ink"]
	match kind:
		"sun":
			tint = palette["accent"]
		"lock":
			file = "lock" if locked else "unlock"
			tint = palette["accent"] if locked else palette["ink"]
		"undo":
			tint = Color.WHITE
		"menu", "needles", "hook":
			pass
		_:
			return
	var texture := _mark_texture(file)
	if texture == null:
		return
	draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false, tint)


func _draw_minus() -> void:
	var side := minf(size.x, size.y)
	if side < 2.0:
		return
	var center := size * 0.5
	var radius := side * 0.38
	var stroke := maxf(1.6, side * 0.09)
	draw_arc(center, radius, 0.0, TAU, 48, Color.WHITE, stroke, true)
	var bar := radius * 0.72
	draw_line(center - Vector2(bar, 0.0), center + Vector2(bar, 0.0), Color.WHITE, stroke, true)


static var _cache := {}


static func _mark_texture(file: String) -> Texture2D:
	if _cache.has(file):
		return _cache[file]
	var texture: Texture2D = load("res://assets/marks/%s.png" % file)
	_cache[file] = texture
	return texture
