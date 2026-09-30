extends Node

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	var click := load("res://assets/sfx/click.wav")
	if click is AudioStream:
		_player.stream = click


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
	if not AppSettings.flag("sound"):
		return
	if _player == null or _player.stream == null:
		return
	_player.play()


func play_wrap_sound() -> void:
	play_tick_sound()


func _can_vibrate() -> bool:
	if not AppSettings.flag("haptics"):
		return false
	var os_name := OS.get_name()
	return os_name == "Android" or os_name == "iOS"


func _vibrate(duration_ms: int) -> void:
	if not _can_vibrate():
		return
	Input.vibrate_handheld(duration_ms, 0.4)
