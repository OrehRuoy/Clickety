extends Control


func _ready() -> void:
	var message := preload("res://tools/contrast_check.gd").run()
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if message == "PASS" else 1)
