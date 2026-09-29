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
@onready var _counter_name: Label = %CounterName
@onready var _numeral: Label = %Numeral
@onready var _target: Label = %Target
@onready var _progress: ProgressBar = %Progress
@onready var _linked: Label = %Linked
@onready var _hint: Label = %Hint
@onready var _lock_message: Label = %LockMessage
@onready var _minus: Button = %Minus
@onready var _undo: Button = %Undo
@onready var _unlock_timer: Timer = %UnlockTimer
@onready var _spike: VBoxContainer = %Spike
@onready var _spike_status: Label = %SpikeStatus

var _locked := false
var _hint_taps := 0
var _name_taps := 0
var _spike_value := 0
var _saw_wrap := false
var _pulse: Tween


func _ready() -> void:
	_paint()
	_apply_numeral_font()
	for button in [_project_name, _lock_button, _menu, _big_tap, _minus, _undo]:
		_let_press_through(button)
	_project_name.pressed.connect(_on_project_pressed)
	_menu.pressed.connect(_on_menu_pressed)
	%Write42.pressed.connect(_on_write_42)
	%PlusOne.pressed.connect(_on_spike_plus)
	%ReadPending.pressed.connect(_on_read_pending)
	_show_spike("idle")
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
	_numeral.resized.connect(_center_numeral)
	get_viewport().size_changed.connect(_fit_layout)
	_linked.visible = false
	_set_awake(true)
	_refresh()
	if OS.is_debug_build():
		var project := Store.active_project()
		var counter := _main_counter(project)
		print("Clickety counter: %s / %s %d" % [
			project.get("name", ""),
			counter.get("name", ""),
			int(counter.get("value", 0)),
		])


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
	var palette := Palette.colors("warm")
	_background.color = palette["bg"]
	_divider.color = palette["muted"]
	_tint(_counter_name, palette["muted"])
	_tint(_target, palette["muted"])
	_tint(_hint, palette["muted"])
	_tint(_lock_message, palette["accent"])
	_tint(_numeral, palette["ink"])
	var track := StyleBoxFlat.new()
	track.bg_color = palette["muted"]
	track.bg_color.a = 0.35
	track.set_corner_radius_all(3)
	track.content_margin_top = 2
	track.content_margin_bottom = 2
	var fill := StyleBoxFlat.new()
	fill.bg_color = palette["accent"]
	fill.set_corner_radius_all(3)
	_progress.add_theme_stylebox_override("background", track)
	_progress.add_theme_stylebox_override("fill", fill)


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
	var counter := _main_counter(project)
	_project_name.text = str(project.get("name", "My project"))
	_counter_name.text = str(counter.get("name", "Row")) if not counter.is_empty() else "Row"
	_numeral.text = str(int(counter.get("value", 0)))
	var target := int(project.get("target", 0))
	var show_target := target > 0
	_target.visible = show_target
	_progress.visible = show_target
	if show_target:
		_target.text = "of %d" % target
		_progress.max_value = float(target)
		_progress.value = float(mini(int(counter.get("value", 0)), target))
	var undo_list = project.get("undo", [])
	_undo.disabled = typeof(undo_list) != TYPE_ARRAY or undo_list.is_empty()
	if _undo.get_child_count() > 0:
		_undo.get_child(0).modulate.a = 0.4 if _undo.disabled else 1.0
	var hint_done := bool(Store.hints().get("tap", false))
	_hint.visible = not _locked and not hint_done
	if _hint.visible:
		_hint.modulate.a = 1.0
	_lock_message.visible = _locked
	_linked.visible = false
	_fit_layout()


func _fit_layout() -> void:
	var width := get_viewport().get_visible_rect().size.x
	_column.custom_minimum_size.x = Layout.column_width(width)
	var digits := maxi(_numeral.text.length(), 1)
	var base := 240 if width >= _IPAD_WIDTH else 160
	if digits >= 4:
		base = int(round(float(base) * 3.0 / float(digits)))
	_numeral.add_theme_font_size_override("font_size", maxi(base, 48))
	_center_numeral()


func _center_numeral() -> void:
	_numeral.pivot_offset = _numeral.size * 0.5


func _on_store_changed(_project_id: String) -> void:
	_refresh()


func _on_wrapped(_project_id: String, _counter_ids: Array) -> void:
	_saw_wrap = true


func _on_tap() -> void:
	if _locked:
		return
	var counter := _main_counter(Store.active_project())
	if counter.is_empty():
		return
	_saw_wrap = false
	Store.tap(str(counter["id"]))
	if _saw_wrap:
		Feedback.wrap()
	else:
		Feedback.tick()
	_pulse_numeral()
	_count_hint()


func _on_minus() -> void:
	var counter := _main_counter(Store.active_project())
	if counter.is_empty():
		return
	Store.minus(str(counter["id"]))


func _on_undo() -> void:
	Store.undo()


func _on_project_pressed() -> void:
	_name_taps += 1
	if _name_taps >= 5:
		_spike.visible = true


func _on_write_42() -> void:
	_spike_value = 42
	WidgetSync.push_test(_spike_value)
	_show_spike("wrote %d" % _spike_value)


func _on_spike_plus() -> void:
	_spike_value += 1
	WidgetSync.push_test(_spike_value)
	_show_spike("wrote %d" % _spike_value)


func _on_read_pending() -> void:
	var pending := WidgetSync.take_pending()
	_show_spike("pending %s" % JSON.stringify(pending))


func _show_spike(result: String) -> void:
	_spike_status.text = "available: %s\n%s" % [str(WidgetSync.available()), result]


func _on_menu_pressed() -> void:
	pass


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
	_pulse = create_tween()
	_pulse.tween_property(_numeral, "scale", Vector2(1.05, 1.05), 0.04)
	_pulse.tween_property(_numeral, "scale", Vector2.ONE, 0.04)


func _set_awake(on: bool) -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.screen_set_keep_on(on)
	if is_node_ready():
		_sun.visible = on


func _main_counter(project: Dictionary) -> Dictionary:
	for counter in project.get("counters", []):
		if typeof(counter) == TYPE_DICTIONARY and str(counter.get("role", "")) == "main":
			return counter
	return {}


func _tint(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)


func _let_press_through(button: Button) -> void:
	for child in button.get_children():
		_ignore_tree(child)


func _ignore_tree(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_tree(child)
