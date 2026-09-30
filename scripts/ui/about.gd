extends Control

var _wordmark: TextureRect


func _ready() -> void:
	_wordmark = Mark.wordmark(200.0, 48.0)
	%Column.add_child(_wordmark)
	%Column.move_child(_wordmark, %Name.get_index())
	%Name.visible = false
	%Icon.custom_minimum_size = Vector2(96, 96)
	_paint()
	AppSettings.changed.connect(_on_appearance)
	%Back.pressed.connect(_on_back)
	%Privacy.pressed.connect(_on_privacy)
	%Email.pressed.connect(_on_email)
	%Name.text = AppInfo.DISPLAY_NAME
	%Version.text = "Version %s" % str(ProjectSettings.get_setting("application/config/version"))
	%Email.text = AppInfo.SUPPORT_EMAIL
	get_viewport().size_changed.connect(_fit_column)
	call_deferred("_fit_column")


func _paint() -> void:
	var palette := Palette.current()
	%Background.color = palette["bg"]
	_wordmark.modulate = palette["ink"]
	%Copy.add_theme_color_override("font_color", palette["ink"])
	%Credits.add_theme_color_override("font_color", palette["muted"])
	%Version.add_theme_color_override("font_color", palette["muted"])


func _on_appearance(key: String) -> void:
	if key == "theme" or key == "text_size":
		_paint()


func _on_privacy() -> void:
	if AppInfo.PRIVACY_URL == "":
		return
	OS.shell_open(AppInfo.PRIVACY_URL)


func _on_email() -> void:
	if AppInfo.SUPPORT_EMAIL == "":
		return
	OS.shell_open("mailto:" + AppInfo.SUPPORT_EMAIL)


func _fit_column() -> void:
	if is_inside_tree():
		Layout.fit_column(%Column)


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
