extends Node

var haptics_enabled := true
var sound_enabled := false


func tick() -> void:
	_vibrate(8)
	play_tick_sound()


func wrap() -> void:
	_vibrate(8)
	play_wrap_sound()
	if not _can_vibrate():
		return
	await get_tree().create_timer(0.09).timeout
	_vibrate(8)


func play_tick_sound() -> void:
	pass


func play_wrap_sound() -> void:
	pass


func _can_vibrate() -> bool:
	if not haptics_enabled:
		return false
	var os_name := OS.get_name()
	return os_name == "Android" or os_name == "iOS"


func _vibrate(duration_ms: int) -> void:
	if not _can_vibrate():
		return
	Input.vibrate_handheld(duration_ms, 0.4)
