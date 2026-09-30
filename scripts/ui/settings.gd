extends Control

const THEME_CHOICES := [
	["system", "System"],
	["warm", "Warm"],
	["night", "Night"],
	["contrast", "High contrast"],
]
const SIZE_CHOICES := [
	["small", "Small"],
	["default", "Default"],
	["large", "Large"],
	["huge", "Huge"],
]

var _loading := false
var _keep: CheckButton
var _haptics: CheckButton
var _sound: CheckButton
var _hands: CheckButton
var _motion: CheckButton
var _daily: CheckButton
var _time: Label
var _reminder: Label
var _unlock: Button
var _status: Label
var _saved: Label
var _review_note: Label
var _sections: Array[Label] = []
var _rows: Array[Button] = []
var _theme_buttons := {}
var _size_buttons := {}
var _checks: Array[CheckButton] = []


func _ready() -> void:
	%Back.pressed.connect(_on_back)
	_build()
	AppSettings.changed.connect(_on_changed)
	Purchase.unlocked_changed.connect(_on_unlocked)
	Purchase.purchase_error.connect(_on_purchase_error)
	NotifyService.reminder_message.connect(_on_reminder_message)
	get_viewport().size_changed.connect(_fit_column)
	TouchScroll.protect(%Scroll)
	call_deferred("_fit_column")
	_sync()
	_paint()


func _build() -> void:
	var body: VBoxContainer = %Body
	_section(body, "Counting")
	_keep = _check(body, "Keep screen awake", _on_keep)
	_haptics = _check(body, "Haptics", _on_haptics)
	_sound = _check(body, "Tap sound", _on_sound)
	_hands = _check(body, "Swap −1 / Undo", _on_hands)
	_section(body, "Look")
	_sections.append(_label(body, "Theme"))
	for item in THEME_CHOICES:
		var theme_id := str(item[0])
		_theme_buttons[theme_id] = _choice(body, str(item[1]), _on_theme.bind(theme_id))
	_sections.append(_label(body, "Text size"))
	for item in SIZE_CHOICES:
		var size_id := str(item[0])
		_size_buttons[size_id] = _choice(body, str(item[1]), _on_size.bind(size_id))
	_motion = _check(body, "Reduce motion", _on_motion)
	_section(body, "Reminders")
	_daily = _check(body, "Daily reminder", _on_daily)
	var time_row := HBoxContainer.new()
	time_row.add_theme_constant_override("separation", 8)
	body.add_child(time_row)
	var hour_down := _choice(time_row, "Hour −", _step_hour.bind(-1))
	hour_down.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_time = _label(time_row, _clock_text())
	_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hour_up := _choice(time_row, "Hour +", _step_hour.bind(1))
	hour_up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var minute_row := HBoxContainer.new()
	minute_row.add_theme_constant_override("separation", 8)
	body.add_child(minute_row)
	var minute_down := _choice(minute_row, "Min −", _step_minute.bind(-1))
	minute_down.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var minute_up := _choice(minute_row, "Min +", _step_minute.bind(1))
	minute_up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reminder = _label(body, "")
	_reminder.visible = false
	if OS.is_debug_build() and not AppInfo.SCREENSHOT_MODE:
		_choice(body, "Test notification in 1 minute", _on_test_reminder)
		_choice(body, "Preview enjoying question", _on_preview_enjoying)
	_section(body, "Purchase")
	_unlock = _choice(body, "Unlock", _on_unlock_row)
	_choice(body, "Restore purchases", _on_restore)
	_status = _label(body, "")
	_status.visible = false
	_section(body, "Your data")
	_choice(body, "Save a backup file", _on_save_backup)
	_choice(body, "Restore from a backup file", _on_open_restore)
	_saved = _label(body, "")
	_saved.visible = false
	_section(body, "About")
	_choice(body, "Leave a review", _on_leave_review)
	_review_note = _label(body, "")
	_review_note.visible = false
	_choice(body, "About", _on_about)


func _section(parent: VBoxContainer, text: String) -> void:
	var label := _label(parent, text)
	_sections.append(label)


func _label(parent: Container, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label


func _check(parent: VBoxContainer, text: String, handler: Callable) -> CheckButton:
	var button := CheckButton.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(handler)
	parent.add_child(button)
	_checks.append(button)
	return button


func _choice(parent: Container, text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(handler)
	parent.add_child(button)
	_rows.append(button)
	return button


func _sync() -> void:
	_loading = true
	_keep.set_pressed_no_signal(AppSettings.flag("keep_awake"))
	_haptics.set_pressed_no_signal(AppSettings.flag("haptics"))
	_sound.set_pressed_no_signal(AppSettings.flag("sound"))
	_hands.set_pressed_no_signal(AppSettings.flag("swap_hands"))
	_motion.set_pressed_no_signal(AppSettings.flag("reduce_motion"))
	if _daily != null:
		_daily.set_pressed_no_signal(AppSettings.flag("daily"))
		var reminder_locked := not Purchase.is_unlocked()
		_daily.text = "Daily reminder"
		Mark.show_lock(_daily, reminder_locked)
	_loading = false
	var owned := Purchase.is_unlocked()
	_unlock.text = "Unlocked" if owned else "Unlock"
	Mark.show_lock(_unlock, true, not owned)


func _paint() -> void:
	var palette := Palette.current()
	%Background.color = palette["bg"]
	Palette.paint_back(%Back)
	Palette.paint_scroll(%Scroll)
	for label in _sections:
		label.add_theme_color_override("font_color", palette["muted"])
	if _status != null:
		_status.add_theme_color_override("font_color", palette["muted"])
	if _saved != null:
		_saved.add_theme_color_override("font_color", palette["muted"])
	if _review_note != null:
		_review_note.add_theme_color_override("font_color", palette["muted"])
	if _time != null:
		_time.text = _clock_text()
	if _reminder != null:
		_reminder.text = NotifyService.message()
		_reminder.visible = _reminder.text != ""
		_reminder.add_theme_color_override("font_color", palette["accent"])
	for button in _rows:
		_mark(button, false, palette)
	for key in _theme_buttons:
		_mark(_theme_buttons[key], str(key) == AppSettings.choice("theme"), palette)
	for key in _size_buttons:
		_mark(_size_buttons[key], str(key) == AppSettings.choice("text_size"), palette)
	for button in _checks:
		_paint_check(button, palette)


func _mark(button: Button, selected: bool, palette: Dictionary) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = palette["surface"]
	box.set_corner_radius_all(12)
	box.content_margin_left = 46 if button.get_node_or_null("LockMark") != null else 16
	box.content_margin_right = 16
	if selected:
		box.border_color = palette["accent"]
		box.set_border_width_all(3)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, box)
	button.add_theme_color_override("font_color", palette["ink"])
	button.add_theme_color_override("font_disabled_color", palette["muted"])


func _paint_check(button: CheckButton, palette: Dictionary) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = palette["surface"]
	box.set_corner_radius_all(12)
	var has_lock := button.get_node_or_null("LockMark") != null
	box.content_margin_left = 46 if has_lock else 16
	box.content_margin_right = 76
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, box)
	var ink: Color = palette["ink"]
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)
	button.add_theme_color_override("font_disabled_color", palette["muted"])


func _on_changed(_key: String) -> void:
	_sync()
	_paint()


func _on_unlocked(_is_on: bool) -> void:
	_sync()
	_paint()


func _on_purchase_error(message: String) -> void:
	_status.text = message
	_status.visible = message != ""


func _on_keep() -> void:
	if _loading:
		return
	AppSettings.set_flag("keep_awake", _keep.button_pressed)


func _on_haptics() -> void:
	if _loading:
		return
	AppSettings.set_flag("haptics", _haptics.button_pressed)


func _on_sound() -> void:
	if _loading:
		return
	AppSettings.set_flag("sound", _sound.button_pressed)


func _on_hands() -> void:
	if _loading:
		return
	AppSettings.set_flag("swap_hands", _hands.button_pressed)


func _on_motion() -> void:
	if _loading:
		return
	AppSettings.set_flag("reduce_motion", _motion.button_pressed)


func _on_daily() -> void:
	if _loading:
		return
	if _daily.button_pressed and not Purchase.is_unlocked():
		_daily.set_pressed_no_signal(false)
		Purchase.set_intent("", "settings")
		get_tree().change_scene_to_file("res://scenes/unlock.tscn")
		return
	NotifyService.set_daily(_daily.button_pressed)
	_daily.set_pressed_no_signal(AppSettings.flag("daily"))
	_paint()


func _step_hour(delta: int) -> void:
	AppSettings.set_number("daily_hour", AppSettings.number("daily_hour") + delta)
	_after_time_change()


func _step_minute(delta: int) -> void:
	AppSettings.set_number("daily_minute", AppSettings.number("daily_minute") + delta * 5)
	_after_time_change()


func _after_time_change() -> void:
	if AppSettings.flag("daily"):
		NotifyService.reschedule()
	_paint()


func _clock_text() -> String:
	var hour := AppSettings.number("daily_hour")
	var minute := AppSettings.number("daily_minute")
	var suffix := "AM" if hour < 12 else "PM"
	var shown := hour % 12
	if shown == 0:
		shown = 12
	return "%d:%02d %s" % [shown, minute, suffix]


func _on_reminder_message(_text: String) -> void:
	_sync()
	_paint()


func _on_test_reminder() -> void:
	NotifyService.test_soon()


func _on_leave_review() -> void:
	Purchase.request_review()
	if OS.get_name() == "iOS" or _review_note == null:
		return
	_review_note.text = "The review sheet opens in the iPhone app."
	_review_note.visible = true


func _on_preview_enjoying() -> void:
	var prompt: Object = (load("res://scripts/ui/enjoying.gd") as GDScript).new()
	prompt.set("preview", true)
	add_child(prompt)


func _on_theme(theme_name: String) -> void:
	AppSettings.set_choice("theme", theme_name)


func _on_size(size_name: String) -> void:
	AppSettings.set_choice("text_size", size_name)


func _on_unlock_row() -> void:
	if Purchase.is_unlocked():
		return
	Purchase.set_intent("", "settings")
	get_tree().change_scene_to_file("res://scenes/unlock.tscn")


func _on_restore() -> void:
	Purchase.restore()


func _on_save_backup() -> void:
	var path := Backup.write_export("user://", Store.snapshot(), AppSettings.snapshot())
	_saved.text = "Saved. Find it in Files → On My iPhone → %s → Exports." % AppInfo.DISPLAY_NAME
	_saved.visible = true
	if OS.get_name() != "iOS":
		print(ProjectSettings.globalize_path(path))


func _on_open_restore() -> void:
	get_tree().change_scene_to_file("res://scenes/backup.tscn")


func _on_about() -> void:
	get_tree().change_scene_to_file("res://scenes/about.tscn")


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/counter.tscn")
