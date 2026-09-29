extends Control

@onready var _result: Label = %Result


func _ready() -> void:
	var counter := (load("res://scenes/counter.tscn") as PackedScene).instantiate()
	add_child(counter)
	await get_tree().process_frame
	await get_tree().process_frame
	var message := _check(counter)
	_result.text = message
	print(message)
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)


func _check(counter: Node) -> String:
	var view := counter.get_viewport().get_visible_rect()
	if view.size.x < 100.0 or view.size.y < 100.0:
		return "FAIL: viewport %s" % view.size
	var minus := counter.get_node("%Minus") as Button
	var undo := counter.get_node("%Undo") as Button
	if minus.size.x < 64.0 or minus.size.y < 56.0:
		return "FAIL: minus size %s" % minus.size
	if undo.size.x < 64.0 or undo.size.y < 56.0:
		return "FAIL: undo size %s" % undo.size
	if undo.get_global_rect().end.y > view.end.y - 15.0:
		return "FAIL: undo sits under the bottom gap %s" % undo.get_global_rect()
	var tap := counter.get_node("%BigTap") as Button
	var divider := counter.get_node("%Divider") as ColorRect
	if tap.get_global_rect().end.y > divider.get_global_rect().position.y + 1.0:
		return "FAIL: tap overlaps the bottom bar"
	if tap.get_global_rect().position.y < 40.0:
		return "FAIL: tap covers the top bar"
	var numeral := counter.get_node("%Numeral") as Label
	var width := view.size.x
	var expected := 240 if width >= 700.0 else 160
	var font_size := numeral.get_theme_font_size("font_size")
	if font_size != expected:
		return "FAIL: numeral %d want %d at width %d" % [font_size, expected, int(width)]
	var project := Store.active_project()
	var project_name := counter.get_node("%ProjectName") as Button
	if project_name.text != str(project.get("name", "")):
		return "FAIL: project name %s" % project_name.text
	if (counter.get_node("%Linked") as CanvasItem).visible:
		return "FAIL: linked line is showing"
	if (counter.get_node("%LockMessage") as CanvasItem).visible:
		return "FAIL: lock message is showing"
	var hint := counter.get_node("%Hint") as Label
	var hint_done := bool(Store.hints().get("tap", false))
	if hint.visible == hint_done:
		return "FAIL: hint visible=%s done=%s" % [hint.visible, hint_done]
	if hint.text != "Tap anywhere to count":
		return "FAIL: hint text"
	return "PASS"
