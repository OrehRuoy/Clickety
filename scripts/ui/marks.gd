class_name Mark
extends Control

@export var kind := "sun"
var locked := false


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func _draw() -> void:
	var palette := Palette.colors("warm")
	var ink: Color = palette["ink"]
	var accent: Color = palette["accent"]
	match kind:
		"sun":
			_sun(accent)
		"lock":
			_lock(accent if locked else ink)
		"menu":
			_menu(ink)
		"minus":
			_minus(ink)
		"undo":
			_undo(ink)


func _sun(color: Color) -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.22
	draw_circle(center, radius, color)
	var inner := radius + 2.0
	var outer := minf(size.x, size.y) * 0.46
	for i in 8:
		var dir := Vector2.from_angle(float(i) * TAU / 8.0)
		draw_line(center + dir * inner, center + dir * outer, color, 2.0, true)


func _lock(color: Color) -> void:
	var body := Rect2(size.x * 0.22, size.y * 0.48, size.x * 0.56, size.y * 0.36)
	draw_rect(body, color, true)
	var center := Vector2(size.x * 0.5, size.y * 0.48)
	var radius := size.x * 0.2
	if locked:
		draw_arc(center, radius, PI, TAU, 16, color, 2.4, true)
	else:
		draw_arc(center + Vector2(size.x * 0.1, -size.y * 0.06), radius, PI * 1.15, TAU, 14, color, 2.4, true)


func _menu(color: Color) -> void:
	var y := size.y * 0.5
	var mid := size.x * 0.5
	var gap := size.x * 0.22
	var radius := minf(size.x, size.y) * 0.08
	draw_circle(Vector2(mid - gap, y), radius, color)
	draw_circle(Vector2(mid, y), radius, color)
	draw_circle(Vector2(mid + gap, y), radius, color)


func _minus(color: Color) -> void:
	var y := size.y * 0.5
	draw_line(Vector2(size.x * 0.15, y), Vector2(size.x * 0.85, y), color, 2.6, true)


func _undo(color: Color) -> void:
	var center := Vector2(size.x * 0.56, size.y * 0.52)
	var radius := minf(size.x, size.y) * 0.32
	var end := PI * 1.45
	draw_arc(center, radius, 0.5, end, 18, color, 2.2, true)
	var tip := center + Vector2.from_angle(end) * radius
	var forward := Vector2.from_angle(end + PI * 0.5).normalized()
	var side := forward.orthogonal().normalized()
	draw_colored_polygon(PackedVector2Array([
		tip + forward * 6.0,
		tip - side * 4.0,
		tip + side * 4.0,
	]), color)
