extends Node

signal changed
signal unlocked_changed(is_on: bool)
signal price_ready(price: String)
signal purchase_error(message: String)

const DATA_DIR := "user://data"
const FILE_NAME := "entitlement.json"

var intent := ""
var intent_return := "projects"

var _unlocked := false
var _since := 0
var _source := ""
var _busy := false
var _price := ""
var _title := ""
var _price_ready := false
var _price_failed := false
var _bridge: Object = null
var _open_presets := false


func _ready() -> void:
	_load()
	if Engine.has_singleton("StoreKit"):
		_bridge = Engine.get_singleton("StoreKit")
		_bridge.purchase_updated.connect(_on_purchase_updated)
		_bridge.purchase_failed.connect(_on_purchase_failed)
		_bridge.entitlements_updated.connect(_on_entitlements)
		_bridge.products_loaded.connect(_on_products_loaded)
		_bridge.products_failed.connect(_on_products_failed)
		_bridge.initialize(AppInfo.IAP_PRODUCT_ID)
		if bool(_bridge.has_lifetime()) and not _unlocked:
			_grant("purchase")


func is_unlocked() -> bool:
	if _unlocked:
		return true
	return _bridge != null and bool(_bridge.has_lifetime())


func store_connected() -> bool:
	return _bridge != null


func price_failed() -> bool:
	return _price_failed


func price_text() -> String:
	_pull_live_price()
	if _price_ready and _price != "":
		return _price
	return ""


func product_title() -> String:
	return _title


func consider_review() -> void:
	var now := int(Time.get_unix_time_from_system())
	if not ReviewGate.allowed(now, AppSettings.installed_at(), AppSettings.review_last(), AppSettings.review_count()):
		return
	request_review()
	AppSettings.mark_review(now)


func request_review() -> void:
	if _bridge != null and _bridge.has_method("request_review"):
		_bridge.request_review()
		return
	if OS.is_debug_build():
		print("Purchase: review prompt skipped (no StoreKit)")


func set_intent(kind: String, return_to: String) -> void:
	intent = kind
	intent_return = return_to


func clear_intent() -> void:
	intent = ""
	intent_return = "projects"


func arm_presets() -> void:
	_open_presets = true


func take_open_presets() -> bool:
	var open := _open_presets
	_open_presets = false
	return open


func set_pretend(on: bool) -> void:
	if not OS.is_debug_build():
		return
	if on:
		_grant("pretend")
		return
	if _source == "purchase":
		unlocked_changed.emit(true)
		changed.emit()
		return
	_unlocked = false
	_source = ""
	_since = 0
	_write()
	unlocked_changed.emit(false)
	changed.emit()


func buy() -> void:
	if _busy:
		return
	_busy = true
	if _bridge != null:
		_bridge.purchase(AppInfo.IAP_PRODUCT_ID)
		return
	if OS.is_debug_build():
		_fake_grant()
		return
	_fail("No connection to the App Store. Check your network and try again.")


func restore() -> void:
	if _busy:
		return
	_busy = true
	if _bridge != null:
		_bridge.restore()
		return
	if OS.is_debug_build():
		_fake_grant()
		return
	_fail("No connection to the App Store. Check your network and try again.")


func message_for(plugin_text: String) -> String:
	var text := plugin_text.strip_edges()
	if text == "" or text == "Purchase cancelled.":
		return ""
	if text == "Waiting for approval.":
		return "Waiting for approval (Ask to Buy). It unlocks by itself once approved."
	if text == "Nothing to restore.":
		return "No previous unlock found for this Apple ID."
	return "Purchase didn't go through. You weren't charged.\n%s" % text


func reload_cache() -> void:
	_load()


func _fake_grant() -> void:
	await get_tree().create_timer(1.0).timeout
	if not _busy:
		return
	_grant("purchase")


func _grant(source: String) -> void:
	_busy = false
	_unlocked = true
	_source = source
	if _since == 0:
		_since = int(Time.get_unix_time_from_system())
	_write()
	unlocked_changed.emit(true)
	changed.emit()


func _fail(plugin_text: String) -> void:
	_busy = false
	var message := message_for(plugin_text)
	if message != "":
		purchase_error.emit(message)


func _on_purchase_updated(product_id: String) -> void:
	if product_id != "" and product_id != AppInfo.IAP_PRODUCT_ID:
		return
	_grant("purchase")


func _on_purchase_failed(plugin_text: String) -> void:
	_fail(plugin_text)


func _on_entitlements(unlocked: bool) -> void:
	if unlocked:
		_grant("purchase")
	else:
		_busy = false


func _on_products_loaded(price: String) -> void:
	_price = price.strip_edges()
	_price_ready = _price != ""
	_price_failed = not _price_ready
	if _bridge != null and _bridge.has_method("get_title"):
		_title = str(_bridge.get_title())
	if _price_ready:
		price_ready.emit(_price)


func _on_products_failed(plugin_text: String) -> void:
	_price_failed = true
	_fail(plugin_text)


func _pull_live_price() -> void:
	if _bridge == null or not _bridge.has_method("get_price"):
		return
	var live := str(_bridge.get_price()).strip_edges()
	if live == "":
		return
	_price = live
	_price_ready = true
	_price_failed = false
	if _bridge.has_method("get_title"):
		var live_title := str(_bridge.get_title()).strip_edges()
		if live_title != "":
			_title = live_title


func _load() -> void:
	_unlocked = false
	_since = 0
	_source = ""
	var path := _path()
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_unlocked = bool(parsed.get("unlocked", false))
	_since = int(parsed.get("since", 0))
	_source = str(parsed.get("source", "pretend" if _unlocked else ""))


func _write() -> void:
	if not _unlocked and not OS.is_debug_build():
		return
	var abs := ProjectSettings.globalize_path(DATA_DIR)
	DirAccess.make_dir_recursive_absolute(abs)
	var main_path := _path()
	var tmp_path := main_path + ".tmp"
	var data := {
		"version": 1,
		"unlocked": _unlocked,
		"product_id": AppInfo.IAP_PRODUCT_ID if _unlocked else "",
		"since": _since,
		"source": _source if _unlocked else "",
	}
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Clickety could not open %s" % tmp_path)
		return
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	var renamed := DirAccess.rename_absolute(tmp_path, main_path)
	if renamed != OK:
		DirAccess.remove_absolute(main_path)
		renamed = DirAccess.rename_absolute(tmp_path, main_path)
		if renamed != OK:
			push_error("Clickety could not replace %s (%s)" % [main_path, error_string(renamed)])


func _path() -> String:
	return DATA_DIR.path_join(FILE_NAME)
