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


static func wordmark(width: float, height: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load("res://assets/marks/wordmark.png") as Texture2D
	rect.modulate = Palette.current()["ink"]
	rect.custom_minimum_size = Vector2(width, height)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rect.accessibility_name = AppInfo.DISPLAY_NAME
	return rect


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
	var palette := Palette.current()
	var file := kind
	var tint: Color = palette["ink"]
	match kind:
		"sun":
			tint = palette["accent"]
		"lock":
			file = "lock" if locked else "unlock"
			tint = palette["accent"] if locked else palette["ink"]
		"minus", "undo":
			tint = Color.WHITE
		"menu", "needles", "hook":
			pass
		_:
			return
	var texture := _mark_texture(file)
	if texture == null:
		return
	draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false, tint)


static var _cache := {}


static func _mark_texture(file: String) -> Texture2D:
	if _cache.has(file):
		return _cache[file]
	var texture: Texture2D = load("res://assets/marks/%s.png" % file)
	_cache[file] = texture
	return texture
