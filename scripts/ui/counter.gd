class_name Counter
extends Control

const _IPAD_WIDTH := 700.0

@onready var _background: ColorRect = %Background
@onready var _divider: ColorRect = %Divider
@onready var _column: VBoxContainer = %Column
@onready var _project_name: Button = %ProjectName
@onready var _sun: Control = %Sun
@onready var _lock_button: Button = %LockButton
@onready var _lock_mark: Mark = %LockMark
@onready var _menu: Button = %Menu
@onready var _big_tap: Button = %BigTap
@onready var _counter_name: Button = %CounterName
@onready var _chips: HFlowContainer = %Chips
@onready var _banner: Button = %Banner
@onready var _numeral: Label = %Numeral
@onready var _target: Label = %Target
@onready var _progress: ProgressBar = %Progress
@onready var _linked: Label = %Linked
@onready var _hint: Label = %Hint
@onready var _lock_message: Label = %LockMessage
@onready var _minus: Button = %Minus
@onready var _undo: Button = %Undo
@onready var _unlock_timer: Timer = %UnlockTimer

var _locked := false
var _hint_taps := 0
var _timer_read: Label
var _sheet: ClickSheet
var _clock: Timer
var _saw_wrap := false
var _wrap_ids: Array = []
var _pulse: Tween
var _wash: TextureRect
var _banner_timer: Timer
var _counting: Label


func _ready() -> void:
	_wash = TextureRect.new()
	_wash.texture = load("res://assets/marks/wash.png")
	_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wash.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wash.set_anchors_preset(Control.PRESET_TOP_LEFT)
	add_child(_wash)
	move_child(_wash, 1)
	get_viewport().size_changed.connect(_place_wash)
	_paint()
	_apply_numeral_font()
	for button in [_project_name, _lock_button, _menu, _big_tap, _minus, _undo]:
		_let_press_through(button)
	_counter_name.mouse_filter = Control.MOUSE_FILTER_STOP
	_counter_name.pressed.connect(_on_counter_name)
	_project_name.pressed.connect(_on_project_pressed)
	_menu.pressed.connect(_on_menu_pressed)
	_banner.pressed.connect(_hide_banner)
	_style_banner()
	_banner_timer = Timer.new()
	_banner_timer.one_shot = true
	_banner_timer.wait_time = 1.5
	_banner_timer.timeout.connect(_hide_banner)
	add_child(_banner_timer)
	_counting = Label.new()
	_counting.visible = false
	_counting.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_counting.add_theme_font_size_override("font_size", 18)
	_project_name.get_parent().add_child(_counting)
	_project_name.get_parent().move_child(_counting, 1)
	_timer_read = Label.new()
	_timer_read.visible = false
	_timer_read.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_timer_read.add_theme_font_size_override("font_size", 18)
	_project_name.get_parent().add_child(_timer_read)
	_project_name.get_parent().move_child(_timer_read, 1)
	_sheet = (load("res://scenes/components/sheet.tscn") as PackedScene).instantiate()
	add_child(_sheet)
	_sheet.picked.connect(_on_menu_pick)
	Purchase.purchase_error.connect(_on_purchase_error)
	_clock = Timer.new()
	_clock.wait_time = 1.0
	_clock.timeout.connect(_on_clock)
	add_child(_clock)
	_clock.start()
	_lock_button.button_down.connect(_on_lock_down)
	_lock_button.button_up.connect(_on_lock_up)
	_lock_button.pressed.connect(_on_lock_pressed)
	_big_tap.pressed.connect(_on_tap)
	_minus.pressed.connect(_on_minus)
	_undo.pressed.connect(_on_undo)
	_unlock_timer.one_shot = true
	_unlock_timer.wait_time = 0.6
	_unlock_timer.timeout.connect(_on_unlock_timeout)
	Store.changed.connect(_on_store_changed)
	Store.wrapped.connect(_on_wrapped)
	Store.alerted.connect(_on_alerted)
	_show_alert_texts(Store.take_alert_texts())
	AppSettings.changed.connect(_on_settings_changed)
	_apply_hands()
	_paint()
	_numeral.resized.connect(_center_numeral)
	get_viewport().size_changed.connect(_fit_layout)
	_linked.visible = false
	_set_awake(true)
	_refresh()
	_maybe_enjoying()
	if OS.is_debug_build():
		var project := Store.active_project()
		var counter := _main_counter(project)
		print("Clickety counter: %s / %s %d" % [
			project.get("name", ""),
			counter.get("name", ""),
			int(counter.get("value", 0)),
		])


func _maybe_enjoying() -> void:
	if AppInfo.SCREENSHOT_MODE or not AppSettings.enjoying_due():
		return
	var prompt: Node = (load("res://scripts/ui/enjoying.gd") as GDScript).new()
	add_child(prompt)


func _exit_tree() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.screen_set_keep_on(false)


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_unlock_timer.stop()
		_set_awake(false)
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_set_awake(true)


func _paint() -> void:
	var palette := Palette.current()
	_background.color = palette["bg"]
	var line: Color = palette["muted"]
	line.a = 0.22
	_divider.color = line
	if _wash != null:
		var wash: Color = palette["accent"]
		wash.a = 0.0 if AppSettings.resolved_theme() == "contrast" else 0.16
		_wash.modulate = wash
	_tint(_counter_name, palette["muted"])
	_tint(_target, palette["muted"])
	_tint(_hint, palette["muted"])
	_tint(_lock_message, palette["accent"])
	_tint(_numeral, palette["ink"])
	if _counting != null:
		_counting.add_theme_color_override("font_color", palette["accent"])
	if _timer_read != null:
		_timer_read.add_theme_color_override("font_color", palette["muted"])
	Palette.paint_progress(_progress, palette)
	_paint_bottom()
	_place_wash()


func _place_wash() -> void:
	if _wash == null or not is_node_ready():
		return
	if _numeral.size.x < 1.0 or _numeral.size.y < 1.0:
		return
	var center := _numeral.get_global_rect().get_center() - global_position
	var side := 320.0
	_wash.offset_left = center.x - side * 0.5
	_wash.offset_top = center.y - side * 0.5
	_wash.offset_right = center.x + side * 0.5
	_wash.offset_bottom = center.y + side * 0.5


func _paint_bottom() -> void:
	_style_corner(_minus, true)
	_style_corner(_undo, not _undo.disabled)


func _style_corner(button: Button, live: bool) -> void:
	var palette := Palette.current()
	var ink: Color = palette["ink"] if live else palette["muted"]
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(16)
	box.bg_color = palette["surface"]
	var border: Color = palette["ink"]
	border.a = 0.16 if live else 0.1
	box.border_color = border
	box.set_border_width_all(1)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, box)
	if button.get_child_count() == 0:
		return
	var row := button.get_child(0)
	row.modulate = Color.WHITE
	for node in row.get_children():
		if node is Mark:
			node.modulate = ink
			node.queue_redraw()
		elif node is Label:
			node.modulate = Color.WHITE
			node.add_theme_color_override("font_color", ink)


func _apply_numeral_font() -> void:
	var base_font: Font = load("res://assets/fonts/AtkinsonHyperlegible-Regular.ttf")
	if base_font == null:
		return
	var numeral_font := FontVariation.new()
	numeral_font.base_font = base_font
	numeral_font.opentype_features = {"tnum": 1}
	_numeral.add_theme_font_override("font", numeral_font)


func _refresh() -> void:
	var project := Store.active_project()
	var counter := _focused_counter(project)
	var main := _main_counter(project)
	var on_main := counter.is_empty() or str(counter.get("id", "")) == str(main.get("id", ""))
	_project_name.text = str(project.get("name", "My project"))
	_counter_name.text = str(counter.get("name", "Row")) if not counter.is_empty() else "Row"
	_numeral.text = str(int(counter.get("value", 0)))
	if _counting != null:
		_counting.visible = not on_main and not counter.is_empty()
		if _counting.visible:
			_counting.text = "Counting: %s" % str(counter.get("name", "Counter"))
	var reset_at := int(counter.get("reset_at", 0))
	var target := int(project.get("target", 0)) if on_main else reset_at
	var show_target := target > 0
	_target.visible = show_target
	_progress.visible = show_target
	if show_target:
		_target.text = "of %d" % target
		_progress.max_value = float(target)
		_progress.value = float(mini(int(counter.get("value", 0)), target))
	_rebuild_chips(project, str(counter.get("id", "")))
	var undo_list = project.get("undo", [])
	_undo.disabled = typeof(undo_list) != TYPE_ARRAY or undo_list.is_empty()
	_paint_bottom()
	_place_wash()
	var hint_done := bool(Store.hints().get("tap", false))
	_hint.visible = not _locked and not hint_done
	if _hint.visible:
		_hint.modulate.a = 1.0
	_lock_message.visible = _locked
	_linked.visible = false
	_big_tap.accessibility_name = "Add one to %s, now %s" % [_counter_name.text, _numeral.text]
	_minus.accessibility_name = "Subtract one"
	_undo.accessibility_name = "Undo"
	_refresh_timer(project)
	_fit_layout()


func _fit_layout() -> void:
	var width := get_viewport().get_visible_rect().size.x
	_column.custom_minimum_size.x = Layout.column_width(width)
	var digits := maxi(_numeral.text.length(), 1)
	var base := int(round((240.0 if width >= _IPAD_WIDTH else 160.0) * AppSettings.text_scale()))
	if digits >= 4:
		base = int(round(float(base) * 3.0 / float(digits)))
	_numeral.add_theme_font_size_override("font_size", maxi(base, 48))
	_center_numeral()


func _center_numeral() -> void:
	_numeral.pivot_offset = _numeral.size * 0.5
	_place_wash()


func _on_store_changed(_project_id: String) -> void:
	_refresh()


func _on_alerted(_texts: Array) -> void:
	_show_alert_texts(Store.take_alert_texts())


func _show_alert_texts(texts: Array) -> void:
	for message in texts:
		var banner := (load("res://scenes/components/row_alert_banner.tscn") as PackedScene).instantiate()
		%AlertStack.add_child(banner)
		banner.show_text(str(message))
		Feedback.wrap()


func _on_wrapped(_project_id: String, counter_ids: Array) -> void:
	_saw_wrap = true
	_wrap_ids = counter_ids.duplicate()


func _on_tap() -> void:
	if _locked:
		return
	var project := Store.active_project()
	var counter := _focused_counter(project)
	if counter.is_empty():
		return
	_saw_wrap = false
	_wrap_ids = []
	Store.tap(str(counter["id"]))
	if _saw_wrap:
		Feedback.wrap()
		_show_banner(Store.active_project(), _wrap_ids)
	else:
		Feedback.tick()
	_pulse_numeral()
	_count_hint()


func _on_minus() -> void:
	var counter := _focused_counter(Store.active_project())
	if counter.is_empty():
		return
	Store.minus(str(counter["id"]))


func _on_counter_name() -> void:
	var project := Store.active_project()
	if project.is_empty():
		return
	Store.set_focus(str(project.get("id", "")), "")


func _on_undo() -> void:
	Store.undo()


func _on_project_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/projects.tscn")


func _on_menu_pick(action: String) -> void:
	if action == "details":
		var project := Store.active_project()
		if project.is_empty():
			return
		Store.begin_edit(str(project.get("id", "")), "counter")
		get_tree().change_scene_to_file("res://scenes/project_edit.tscn")
	elif action == "settings":
		get_tree().change_scene_to_file("res://scenes/settings.tscn")
	elif action == "restore":
		Purchase.restore()


func _on_clock() -> void:
	_refresh_timer(Store.active_project())


func _refresh_timer(project: Dictionary) -> void:
	if _timer_read == null:
		return
	var timer = project.get("timer", {})
	var shown := typeof(timer) == TYPE_DICTIONARY and bool(timer.get("shown", false))
	_timer_read.visible = shown
	if shown:
		_timer_read.text = Store.elapsed_text(project)


func _on_menu_pressed() -> void:
	var rows: Array = [
		{"id": "details", "text": "Project details"},
		{"id": "settings", "text": "Settings"},
		{"id": "restore", "text": "Restore purchases"},
		{"id": "cancel", "text": "Cancel"},
	]
	_sheet.present("Menu", rows)


func _on_lock_down() -> void:
	if _locked:
		_unlock_timer.start()


func _on_lock_up() -> void:
	_unlock_timer.stop()


func _on_lock_pressed() -> void:
	if not _locked:
		_set_locked(true)


func _on_unlock_timeout() -> void:
	_set_locked(false)


func _set_locked(locked: bool) -> void:
	_locked = locked
	if locked:
		_unlock_timer.stop()
	_lock_mark.locked = locked
	_lock_mark.queue_redraw()
	_refresh()


func _count_hint() -> void:
	if bool(Store.hints().get("tap", false)):
		return
	_hint_taps += 1
	if _hint_taps < 3:
		return
	Store.set_hint("tap", true)
	var fade := create_tween()
	fade.tween_property(_hint, "modulate:a", 0.0, 0.35)
	fade.finished.connect(func() -> void:
		_hint.visible = false
	)


func _pulse_numeral() -> void:
	_center_numeral()
	if _pulse != null and _pulse.is_valid():
		_pulse.kill()
	_numeral.scale = Vector2.ONE
	if AppSettings.flag("reduce_motion"):
		return
	_pulse = create_tween()
	_pulse.tween_property(_numeral, "scale", Vector2(1.05, 1.05), 0.04)
	_pulse.tween_property(_numeral, "scale", Vector2.ONE, 0.04)


func _set_awake(on: bool) -> void:
	var keep := on and AppSettings.flag("keep_awake")
	if DisplayServer.get_name() != "headless":
		DisplayServer.screen_set_keep_on(keep)
	if is_node_ready():
		_sun.visible = keep


func _apply_hands() -> void:
	var actions := _minus.get_parent()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spacer := actions.get_node_or_null("Spacer") as Control
	if spacer != null:
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_undo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var swapped := AppSettings.flag("swap_hands")
	var first: Node = _undo if swapped else _minus
	var second: Node = _minus if swapped else _undo
	actions.move_child(first, 0)
	if spacer != null:
		actions.move_child(spacer, 1)
	actions.move_child(second, -1)


func _on_settings_changed(_key: String) -> void:
	_paint()
	_style_banner()
	_apply_hands()
	_set_awake(true)
	_redraw_marks(self)
	_refresh()


func _redraw_marks(node: Node) -> void:
	if node is Mark:
		(node as CanvasItem).queue_redraw()
	for child in node.get_children():
		_redraw_marks(child)


func _focused_counter(project: Dictionary) -> Dictionary:
	var focus_id := str(project.get("focus_id", ""))
	if focus_id != "":
		for counter in project.get("counters", []):
			if typeof(counter) == TYPE_DICTIONARY and str(counter.get("id", "")) == focus_id:
				return counter
	return _main_counter(project)


func _rebuild_chips(project: Dictionary, focused_id: String) -> void:
	if _chips == null:
		return
	for child in _chips.get_children():
		_chips.remove_child(child)
		child.free()
	var extras: Array = []
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) != "main":
			extras.append(counter)
	_chips.visible = not extras.is_empty()
	if extras.is_empty():
		return
	var wide := get_viewport().get_visible_rect().size.x >= _IPAD_WIDTH
	var shown := mini(extras.size(), 3)
	for index in shown:
		_chips.add_child(_chip_button(extras[index], focused_id, wide))
	var rest := extras.size() - shown
	if rest > 0:
		var more := Button.new()
		more.text = "+%d more" % rest
		more.focus_mode = Control.FOCUS_NONE
		more.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		more.custom_minimum_size = Vector2(0, 56)
		more.add_theme_font_size_override("font_size", 20 if wide else 16)
		more.pressed.connect(_open_counters)
		_chips.add_child(more)


func _chip_button(counter: Dictionary, focused_id: String, wide: bool) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var font_size := 20 if wide else 16
	var label_text := _chip_text(counter)
	var font: Font = button.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var text_width := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	button.custom_minimum_size = Vector2(ceil(text_width) + 64, 56)
	var focused := str(counter.get("id", "")) == focused_id
	var box := StyleBoxFlat.new()
	box.bg_color = Palette.current()["surface"]
	box.set_corner_radius_all(12)
	box.content_margin_left = 8
	box.content_margin_right = 10
	box.content_margin_top = 6
	box.content_margin_bottom = 6
	if focused:
		box.border_color = Palette.current()["accent"]
		box.set_border_width_all(3)
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, box)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 8
	row.offset_right = -8
	button.add_child(row)
	row.add_child(_chip_badge(int(counter.get("color_idx", 0))))
	var name := Label.new()
	name.text = label_text
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.add_theme_font_size_override("font_size", font_size)
	name.add_theme_color_override("font_color", Palette.current()["ink"])
	name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(name)
	button.pressed.connect(_focus_chip.bind(str(counter.get("id", ""))))
	return button


func _chip_badge(index: int) -> Panel:
	var chip: Dictionary = Palette.chip(index)
	var badge := Panel.new()
	badge.custom_minimum_size = Vector2(28, 28)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var panel := StyleBoxFlat.new()
	panel.bg_color = chip["color"]
	panel.set_corner_radius_all(8)
	badge.add_theme_stylebox_override("panel", panel)
	var letter := Label.new()
	letter.text = str(chip.get("letter", "A"))
	letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	letter.add_theme_color_override("font_color", Palette.chip_ink(index))
	letter.layout_mode = 1
	letter.set_anchors_preset(Control.PRESET_FULL_RECT)
	badge.add_child(letter)
	return badge


func _chip_text(counter: Dictionary) -> String:
	var reset_at := int(counter.get("reset_at", 0))
	if reset_at > 0:
		return "%s %d/%d" % [str(counter.get("name", "Counter")), int(counter.get("value", 0)), reset_at]
	return "%s %d" % [str(counter.get("name", "Counter")), int(counter.get("value", 0))]


func _focus_chip(counter_id: String) -> void:
	var project := Store.active_project()
	if project.is_empty():
		return
	Store.set_focus(str(project.get("id", "")), counter_id)


func _open_counters() -> void:
	var project := Store.active_project()
	if project.is_empty():
		return
	Store.editing_id = str(project.get("id", ""))
	Store.counters_return = "counter"
	get_tree().change_scene_to_file("res://scenes/counters_edit.tscn")


func _style_banner() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Palette.current()["ink"]
	box.set_corner_radius_all(14)
	box.content_margin_left = 16
	box.content_margin_right = 16
	_banner.add_theme_color_override("font_color", Palette.current()["bg"])
	_banner.add_theme_font_size_override("font_size", 18)
	for state in ["normal", "hover", "pressed", "focus"]:
		_banner.add_theme_stylebox_override(state, box)


func _on_purchase_error(message: String) -> void:
	if message == "":
		return
	_banner.text = message
	_banner.visible = true
	_banner_timer.start()


func _show_banner(project: Dictionary, wrapped_ids: Array) -> void:
	var text := _banner_text(project, wrapped_ids)
	if text == "":
		return
	_banner.text = text
	_banner.visible = true
	_banner_timer.start()


func _hide_banner() -> void:
	_banner.visible = false
	if _banner_timer != null:
		_banner_timer.stop()


func _banner_text(project: Dictionary, wrapped_ids: Array) -> String:
	if wrapped_ids.is_empty():
		return ""
	var wrapped_id := str(wrapped_ids[0])
	var follower: Dictionary = {}
	var wrapped: Dictionary = {}
	for counter in project.get("counters", []):
		if typeof(counter) != TYPE_DICTIONARY:
			continue
		if str(counter.get("id", "")) == wrapped_id:
			wrapped = counter
		var link = counter.get("link", {})
		if typeof(link) == TYPE_DICTIONARY and str(link.get("to", "")) == wrapped_id and str(link.get("on", "")) == "wrap":
			follower = counter
	if not follower.is_empty():
		return "%s %d done" % [str(follower.get("name", "Counter")), int(follower.get("value", 0))]
	if wrapped.is_empty():
		return ""
	return "%s %d done" % [str(wrapped.get("name", "Counter")), int(wrapped.get("reset_at", 0))]


func _main_counter(project: Dictionary) -> Dictionary:
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return counter
	return {}


func _tint(control: Control, color: Color) -> void:
	control.add_theme_color_override("font_color", color)


func _let_press_through(button: Button) -> void:
	for child in button.get_children():
		_ignore_tree(child)


func _ignore_tree(node: Node) -> void:
	if node == _counter_name or node == _chips:
		return
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_tree(child)
