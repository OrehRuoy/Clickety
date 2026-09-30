class_name TouchScroll
extends RefCounted

const DRAG_LIMIT := 10.0


static func protect(scroll: ScrollContainer) -> void:
	if scroll == null or not is_instance_valid(scroll):
		return
	scroll.scroll_deadzone = 10
	for button in _buttons(scroll):
		_wrap(scroll, button)


static func adopt(button: BaseButton) -> void:
	var parent := button.get_parent()
	while parent != null and not (parent is ScrollContainer):
		parent = parent.get_parent()
	if parent != null:
		_late.call_deferred(parent, button)


static func _late(scroll: ScrollContainer, button: BaseButton) -> void:
	if is_instance_valid(scroll) and is_instance_valid(button) and button.is_inside_tree():
		scroll.scroll_deadzone = 10
		_wrap(scroll, button)


static func _buttons(root: Node) -> Array[BaseButton]:
	var found: Array[BaseButton] = []
	for child in root.get_children():
		if child is BaseButton:
			found.append(child)
		found.append_array(_buttons(child))
	return found


static func _wrap(scroll: ScrollContainer, button: BaseButton) -> void:
	if button.has_meta("ts_wrapped"):
		return
	button.set_meta("ts_wrapped", true)
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	for connection in button.pressed.get_connections():
		var callback: Callable = connection["callable"]
		button.pressed.disconnect(callback)
		button.pressed.connect(_guarded.bind(button, callback))
	button.gui_input.connect(_on_input.bind(scroll, button))


static func _guarded(button: BaseButton, callback: Callable) -> void:
	if bool(button.get_meta("ts_drag", false)):
		button.set_meta("ts_drag", false)
		if button.toggle_mode:
			button.set_pressed_no_signal(not button.button_pressed)
		return
	callback.call()


static func _on_input(event: InputEvent, scroll: ScrollContainer, button: BaseButton) -> void:
	var down_touch := event as InputEventScreenTouch
	var down_mouse := event as InputEventMouseButton
	if down_touch != null or (down_mouse != null and down_mouse.button_index == MOUSE_BUTTON_LEFT):
		var pressed: bool = down_touch.pressed if down_touch != null else down_mouse.pressed
		if pressed:
			var local: Vector2 = down_touch.position if down_touch != null else down_mouse.position
			button.set_meta("ts_origin", button.get_global_transform() * local)
			button.set_meta("ts_drag", false)
		return
	var delta := 0.0
	var kind := 0
	var here := Vector2.ZERO
	var drag_touch := event as InputEventScreenDrag
	var drag_mouse := event as InputEventMouseMotion
	if drag_touch != null:
		delta = drag_touch.relative.y
		kind = 1
		here = button.get_global_transform() * drag_touch.position
	elif drag_mouse != null and (drag_mouse.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		delta = drag_mouse.relative.y
		kind = 2
		here = button.get_global_transform() * drag_mouse.position
	else:
		return
	var origin: Vector2 = button.get_meta("ts_origin", here)
	if not bool(button.get_meta("ts_drag", false)) and here.distance_to(origin) > DRAG_LIMIT:
		button.set_meta("ts_drag", true)
	if not bool(button.get_meta("ts_drag", false)):
		return
	var frame := Engine.get_process_frames()
	if int(scroll.get_meta("ts_frame", -1)) == frame and int(scroll.get_meta("ts_kind", 0)) != kind:
		return
	scroll.set_meta("ts_frame", frame)
	scroll.set_meta("ts_kind", kind)
	_nudge.call_deferred(scroll, scroll.scroll_vertical, -delta)


static func _nudge(scroll: ScrollContainer, before: int, amount: float) -> void:
	if is_instance_valid(scroll) and scroll.scroll_vertical == before:
		scroll.scroll_vertical = before + int(round(amount))
