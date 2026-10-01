extends Control

var _waiting := false
var _mark: Control
var _wordmark: TextureRect
var _price_label: Label
var _card: PanelContainer
var _lines: Array[Label] = []


func _ready() -> void:
	_wordmark = Mark.wordmark(200.0, 48.0)
	%Column.add_child(_wordmark)
	%Column.move_child(_wordmark, 1)
	_mark = TextureRect.new()
	_mark.texture = load("res://assets/marks/brand.png")
	_mark.custom_minimum_size = Vector2(168, 148)
	_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	%Column.add_child(_mark)
	%Column.move_child(_mark, 2)
	_card = PanelContainer.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 8)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(inner)
	for node_name in ["ProjectsLine", "RepeatLine", "WidgetLine", "AlertsLine", "OnceLine", "FreeLine"]:
		var line: Label = %Column.get_node(node_name)
		if node_name == "WidgetLine":
			line.visible = AppInfo.WIDGET_SHIPPED
		%Column.remove_child(line)
		inner.add_child(line)
		_lines.append(line)
	%Column.add_child(_card)
	%Column.move_child(_card, %Title.get_index() + 1)
	_price_label = Label.new()
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_price_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	%Column.add_child(_price_label)
	%Column.move_child(_price_label, %Unlock.get_index())
	%Title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_paint_theme()
	AppSettings.changed.connect(_on_appearance)
	%Back.pressed.connect(_on_back)
	%Unlock.pressed.connect(_on_unlock)
	%Restore.pressed.connect(_on_restore)
	Purchase.unlocked_changed.connect(_on_unlocked)
	Purchase.price_ready.connect(_on_price)
	Purchase.purchase_error.connect(_show_error)
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")
	_paint_title()
	_paint_button()


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _paint_theme() -> void:
	var palette := Palette.current()
	%Background.color = palette["bg"]
	%Error.add_theme_color_override("font_color", palette["accent"])
	%ErrorDetail.add_theme_color_override("font_color", palette["muted"])
	%Title.add_theme_color_override("font_color", palette["ink"])
	Mark.refresh_wordmark(_wordmark)
	if _mark is TextureRect:
		_mark.modulate = Color.WHITE
	var card := StyleBoxFlat.new()
	card.bg_color = palette["surface"]
	card.set_corner_radius_all(16)
	card.content_margin_left = 16
	card.content_margin_right = 16
	card.content_margin_top = 14
	card.content_margin_bottom = 14
	_card.add_theme_stylebox_override("panel", card)
	_price_label.add_theme_color_override("font_color", palette["ink"])
	for line in _lines:
		var muted := line.name == "OnceLine" or line.name == "FreeLine"
		line.add_theme_color_override("font_color", palette["muted"] if muted else palette["ink"])
	var buy := StyleBoxFlat.new()
	buy.bg_color = palette["accent"]
	buy.set_corner_radius_all(16)
	buy.content_margin_left = 18
	buy.content_margin_right = 18
	for state in ["normal", "hover", "pressed", "focus"]:
		%Unlock.add_theme_stylebox_override(state, buy)
	%Unlock.add_theme_color_override("font_color", palette["accent_ink"])
	%Unlock.add_theme_color_override("font_hover_color", palette["accent_ink"])
	%Unlock.add_theme_color_override("font_pressed_color", palette["accent_ink"])
	%Restore.add_theme_color_override("font_color", palette["muted"])
	Palette.paint_back(%Back)


func _on_appearance(key: String) -> void:
	if key != "theme" and key != "text_size":
		return
	_paint_theme()


func _paint_button() -> void:
	if AppInfo.SCREENSHOT_MODE:
		_price_label.text = ""
		%Unlock.text = "Unlock once"
		%Unlock.disabled = false
		return
	var live := Purchase.price_text()
	var price := live if live != "" else AppInfo.US_PRICE
	_price_label.add_theme_font_size_override("font_size", 34)
	_price_label.text = price
	%Unlock.text = "Unlock for %s" % price
	%Unlock.disabled = Purchase.store_connected() and live == "" and not Purchase.price_failed()


func _paint_title() -> void:
	var title := Purchase.product_title()
	%Title.text = title if title != "" else "Unlock"


func _on_price(_price: String) -> void:
	_paint_title()
	_paint_button()


func _on_unlock() -> void:
	if _waiting:
		return
	_waiting = true
	_clear_error()
	Purchase.buy()


func _on_restore() -> void:
	if _waiting:
		return
	_waiting = true
	_clear_error()
	Purchase.restore()


func _on_unlocked(is_on: bool) -> void:
	if not is_on or not _waiting:
		return
	_waiting = false
	%Unlock.text = "Unlocked — thank you!"
	await get_tree().create_timer(0.4).timeout
	_finish()


func _show_error(message: String) -> void:
	_waiting = false
	if message == "":
		_clear_error()
		return
	var parts := message.split("\n", true, 1)
	%Error.text = parts[0]
	%Error.visible = true
	if parts.size() > 1:
		%ErrorDetail.text = parts[1]
		%ErrorDetail.visible = true
	else:
		%ErrorDetail.visible = false
	_paint_button()


func _clear_error() -> void:
	%Error.visible = false
	%ErrorDetail.visible = false


func _finish() -> void:
	var kind := Purchase.intent
	var back := Purchase.intent_return
	Purchase.clear_intent()
	if kind == "new_project":
		var project := Store.create_project("Project", "knit")
		Store.begin_edit(str(project.get("id", "")), "projects")
		get_tree().change_scene_to_file("res://scenes/project_edit.tscn")
		return
	if kind == "add_counter":
		Purchase.arm_presets()
		get_tree().change_scene_to_file("res://scenes/counters_edit.tscn")
		return
	if kind == "add_alert":
		Store.open_alert_form = true
		get_tree().change_scene_to_file("res://scenes/row_alerts.tscn")
		return
	_leave(back)


func _on_back() -> void:
	var back := Purchase.intent_return
	Purchase.clear_intent()
	_leave(back)


func _leave(back: String) -> void:
	var path := "res://scenes/projects.tscn"
	if back == "counter":
		path = "res://scenes/counter.tscn"
	elif back == "counters":
		path = "res://scenes/counters_edit.tscn"
	elif back == "settings":
		path = "res://scenes/settings.tscn"
	elif back == "alerts":
		path = "res://scenes/row_alerts.tscn"
	get_tree().change_scene_to_file(path)
