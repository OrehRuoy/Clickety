extends Node

signal changed(key: String)

const DATA_DIR := "user://data"
const FILE_NAME := "settings.json"
const THEMES := ["system", "warm", "night", "contrast"]
const SIZES := {
	"small": 0.9,
	"default": 1.0,
	"large": 1.2,
	"huge": 1.45,
}
const FLAGS := ["keep_awake", "haptics", "sound", "reduce_motion", "swap_hands", "daily"]
const NUMBERS := {"daily_hour": 20, "daily_minute": 0}

var _data: Dictionary = {}


func _ready() -> void:
	_data = load_from_dir(DATA_DIR)
	if int(_data.get("installed_at", 0)) <= 0:
		_data["installed_at"] = int(Time.get_unix_time_from_system())
		save_to_dir(DATA_DIR, _data)
	_apply_theme()


func flag(key: String) -> bool:
	return bool(_data.get(key, key == "keep_awake" or key == "haptics"))


func choice(key: String) -> String:
	if key == "theme":
		return str(_data.get("theme", "system"))
	return str(_data.get("text_size", "default"))


func set_flag(key: String, value: bool) -> void:
	if not FLAGS.has(key):
		return
	if _data.has(key) and bool(_data[key]) == value:
		return
	_data[key] = value
	_store(key)


func set_choice(key: String, value: String) -> void:
	if key == "theme":
		if not THEMES.has(value) or choice("theme") == value:
			return
	elif key == "text_size":
		if not SIZES.has(value) or choice("text_size") == value:
			return
	else:
		return
	_data[key] = value
	_store(key)


func resolved_theme() -> String:
	var theme_name := choice("theme")
	if theme_name != "system":
		return theme_name
	if DisplayServer.get_name() == "headless":
		return "warm"
	return "night" if DisplayServer.is_dark_mode() else "warm"


func text_scale() -> float:
	return float(SIZES.get(choice("text_size"), 1.0))


func installed_at() -> int:
	return int(_data.get("installed_at", 0))


func review_last() -> int:
	return int(_data.get("review_last", 0))


func review_count() -> int:
	return int(_data.get("review_count", 0))


func mark_review(now: int) -> void:
	var count := ReviewGate.next_count(now, review_last(), review_count())
	_data["review_last"] = now
	_data["review_count"] = count
	_store("review_last")


func number(key: String) -> int:
	return int(_data.get(key, NUMBERS.get(key, 0)))


func set_number(key: String, value: int) -> void:
	if not NUMBERS.has(key):
		return
	var next := value
	if key == "daily_hour":
		next = posmod(value, 24)
	elif key == "daily_minute":
		next = posmod(value, 60)
	if _data.has(key) and int(_data[key]) == next:
		return
	_data[key] = next
	_store(key)


func reload() -> void:
	_data = load_from_dir(DATA_DIR)
	_apply_theme()
	changed.emit("theme")
	changed.emit("text_size")
	changed.emit("daily")


static func load_from_dir(dir: String) -> Dictionary:
	_ensure_dir(dir)
	var parsed = _read_json(_main_path(dir))
	if parsed == null:
		parsed = _read_json(_main_path(dir) + ".bak")
	if typeof(parsed) != TYPE_DICTIONARY:
		parsed = {}
	return _normalize(parsed)


static func save_to_dir(dir: String, data: Dictionary) -> void:
	_ensure_dir(dir)
	var main_path := _main_path(dir)
	var tmp_path := main_path + ".tmp"
	var bak_path := main_path + ".bak"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Clickety could not open %s (%s)" % [tmp_path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	if FileAccess.file_exists(main_path) and _read_json(main_path) != null:
		if FileAccess.file_exists(bak_path):
			DirAccess.remove_absolute(bak_path)
		var copied := DirAccess.copy_absolute(main_path, bak_path)
		if copied != OK:
			push_error("Clickety could not write %s (%s)" % [bak_path, error_string(copied)])
	var renamed := DirAccess.rename_absolute(tmp_path, main_path)
	if renamed != OK:
		DirAccess.remove_absolute(main_path)
		renamed = DirAccess.rename_absolute(tmp_path, main_path)
		if renamed != OK:
			push_error("Clickety could not replace %s (%s)" % [main_path, error_string(renamed)])


static func _normalize(raw: Dictionary) -> Dictionary:
	var out := {
		"version": 1,
		"keep_awake": true,
		"haptics": true,
		"sound": false,
		"theme": "system",
		"text_size": "default",
		"reduce_motion": false,
		"swap_hands": false,
		"daily": false,
		"daily_hour": 20,
		"daily_minute": 0,
		"installed_at": 0,
		"review_last": 0,
		"review_count": 0,
	}
	for key in FLAGS:
		if typeof(raw.get(key)) == TYPE_BOOL:
			out[key] = raw[key]
	var theme_name := str(raw.get("theme", "system"))
	out["theme"] = theme_name if THEMES.has(theme_name) else "system"
	var size_name := str(raw.get("text_size", "default"))
	out["text_size"] = size_name if SIZES.has(size_name) else "default"
	if typeof(raw.get("daily_hour")) == TYPE_FLOAT or typeof(raw.get("daily_hour")) == TYPE_INT:
		out["daily_hour"] = posmod(int(raw["daily_hour"]), 24)
	if typeof(raw.get("daily_minute")) == TYPE_FLOAT or typeof(raw.get("daily_minute")) == TYPE_INT:
		out["daily_minute"] = posmod(int(raw["daily_minute"]), 60)
	out["installed_at"] = _non_negative(raw, "installed_at")
	out["review_last"] = _non_negative(raw, "review_last")
	out["review_count"] = _non_negative(raw, "review_count")
	return out


static func _non_negative(raw: Dictionary, key: String) -> int:
	var value = raw.get(key, 0)
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return 0
	return maxi(0, int(value))


static func _main_path(dir: String) -> String:
	return dir.path_join(FILE_NAME)


static func _ensure_dir(dir: String) -> void:
	var abs := ProjectSettings.globalize_path(dir)
	var err := DirAccess.make_dir_recursive_absolute(abs)
	if err != OK and err != ERR_ALREADY_EXISTS:
		push_error("Clickety could not create %s (%s)" % [abs, error_string(err)])


static func _read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return parsed


func snapshot() -> Dictionary:
	return _data.duplicate(true)


func apply_snapshot(raw: Dictionary) -> void:
	_data = _normalize(raw)
	save_to_dir(DATA_DIR, _data)
	_apply_theme()
	changed.emit("theme")
	changed.emit("text_size")
	changed.emit("daily")
	NotifyService.sync_from_settings()


func _store(key: String) -> void:
	save_to_dir(DATA_DIR, _data)
	if key == "theme" or key == "text_size":
		_apply_theme()
	changed.emit(key)


func _apply_theme() -> void:
	var theme := load("res://assets/theme.tres") as Theme
	if theme == null:
		return
	var palette := Palette.colors(resolved_theme())
	theme.default_font_size = int(round(18.0 * text_scale()))
	theme.set_color("font_color", "Label", palette["ink"])
	theme.set_color("font_color", "Button", palette["ink"])
	theme.set_color("font_hover_color", "Button", palette["ink"])
	theme.set_color("font_pressed_color", "Button", palette["ink"])
	theme.set_color("font_focus_color", "Button", palette["ink"])
	theme.set_color("font_disabled_color", "Button", palette["muted"])
