extends Control

const _NOTE_LIMIT := 2000

var _column: VBoxContainer
var _note: TextEdit
var _status: Label
var _send: Button
var _busy := false
var preview := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 20
	_fill(self)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect(_on_dim)
	add_child(dim)
	_fill(dim)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_fill(center)
	resized.connect(_fill.bind(self))
	resized.connect(_fill.bind(dim))
	resized.connect(_fill.bind(center))
	call_deferred("_fill", self)
	call_deferred("_fill", dim)
	call_deferred("_fill", center)
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var width := minf(360.0, get_viewport_rect().size.x - 48.0)
	card.custom_minimum_size = Vector2(width, 0)
	var box := AppTheme.card(Palette.current(), 18)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 22
	box.content_margin_bottom = 20
	card.add_theme_stylebox_override("panel", box)
	center.add_child(card)
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 14)
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(_column)
	_show_question()
	if not preview:
		AppSettings.mark_enjoying_asked()


func _fill(node: Control) -> void:
	node.layout_mode = Control.LAYOUT_MODE_ANCHORS
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.offset_left = 0.0
	node.offset_top = 0.0
	node.offset_right = 0.0
	node.offset_bottom = 0.0
	var parent_control := node.get_parent() as Control
	if parent_control != null and parent_control.size.x > 1.0:
		node.position = Vector2.ZERO
		node.size = parent_control.size


func _show_question() -> void:
	_clear()
	_heading("Are you enjoying Clickety?")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_column.add_child(row)
	var yes := _button(row, "Yes")
	Palette.paint_action(yes, true)
	yes.pressed.connect(_on_yes)
	_button(row, "No").pressed.connect(_open_form)


func _open_form() -> void:
	_show_form.call_deferred()


func _show_form() -> void:
	_clear()
	_heading("Send feedback")
	_muted(version_line())
	_muted(device_line())
	_note = TextEdit.new()
	_note.placeholder_text = "What should we change?"
	_note.custom_minimum_size = Vector2(0, 150)
	_note.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_note.focus_mode = Control.FOCUS_CLICK
	_note.text_changed.connect(_on_note)
	_column.add_child(_note)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", Palette.current()["muted"])
	_status.visible = false
	_column.add_child(_status)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_column.add_child(row)
	_button(row, "Not now").pressed.connect(_close)
	_send = _button(row, "Send")
	Palette.paint_action(_send, true)
	var dim := AppTheme.card(Palette.current())
	var dim_color: Color = dim.bg_color
	dim_color.a = 0.55
	dim.bg_color = dim_color
	_send.add_theme_stylebox_override("disabled", dim)
	_send.add_theme_color_override("font_disabled_color", Palette.current()["muted"])
	_send.disabled = true
	_send.pressed.connect(_on_send)


func _on_yes() -> void:
	_close()
	Purchase.request_review()
	AppSettings.mark_review(int(Time.get_unix_time_from_system()))


func _on_note() -> void:
	if _note.text.length() > _NOTE_LIMIT:
		_note.text = _note.text.substr(0, _NOTE_LIMIT)
	if _send != null and not _busy:
		_send.disabled = _note.text.strip_edges() == ""


func _on_send() -> void:
	var text := _note.text.strip_edges()
	if text == "" or _busy:
		return
	_busy = true
	_send.disabled = true
	_set_status("Sending…")
	var payload := {
		"access_key": AppInfo.WEB3FORMS_ACCESS_KEY,
		"subject": "Clickety feedback",
		"from_name": "Clickety",
		"message": text,
		"version": version_line(),
		"system": device_line(),
	}
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_result.bind(http))
	var err := http.request(
		"https://api.web3forms.com/submit",
		["Content-Type: application/json", "Accept: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	if err != OK:
		_fail(http)


func _on_result(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void:
	var ok := false
	if result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		ok = typeof(parsed) == TYPE_DICTIONARY and bool(parsed.get("success", false))
	if http != null:
		http.queue_free()
	if ok:
		_show_thanks()
		return
	_fail(null)


func _fail(http: HTTPRequest) -> void:
	_busy = false
	if http != null:
		http.queue_free()
	if _send != null:
		_send.disabled = _note == null or _note.text.strip_edges() == ""
	_set_status("Couldn't send. Check your connection and try again.")


func _show_thanks() -> void:
	_clear()
	_heading("Sent. Thank you.")
	var close := _button(_column, "Close")
	close.pressed.connect(_close)
	Palette.paint_action(close, true)


func _heading(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Palette.current()["ink"])
	_column.add_child(label)


func _muted(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Palette.current()["muted"])
	_column.add_child(label)


func _button(parent: Container, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	parent.add_child(button)
	return button


func _set_status(text: String) -> void:
	if _status == null:
		return
	_status.text = text
	_status.visible = text != ""


func _clear() -> void:
	if _column == null:
		return
	for child in _column.get_children():
		_column.remove_child(child)
		child.free()
	_note = null
	_status = null
	_send = null
	_busy = false


func _on_dim(event: InputEvent) -> void:
	if _busy:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_close()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_close()


func _close() -> void:
	queue_free()


static func version_line() -> String:
	return "Version %s" % str(ProjectSettings.get_setting("application/config/version"))


static func device_line() -> String:
	var model := OS.get_model_name().strip_edges()
	var os_name := OS.get_name()
	var version := OS.get_version()
	if model == "":
		return "%s %s" % [os_name, version]
	return "%s · %s %s" % [model, os_name, version]
