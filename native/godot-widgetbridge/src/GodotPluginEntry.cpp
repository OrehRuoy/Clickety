// Godot 4.6 plugin glue: C++ linkage (void widgetbridge_init();), same pattern as Oil Due's StoreKit entry.
#include "core/config/engine.h"
#include "core/object/class_db.h"
#include "core/object/object.h"
#include "core/os/memory.h"
#include "core/string/ustring.h"

#include "widget_bridge.h"

class WidgetBridge : public Object {
	GDCLASS(WidgetBridge, Object);

protected:
	static void _bind_methods() {
		ClassDB::bind_method(D_METHOD("is_available"), &WidgetBridge::is_available);
		ClassDB::bind_method(D_METHOD("write_snapshot", "json"), &WidgetBridge::write_snapshot);
		ClassDB::bind_method(D_METHOD("reload"), &WidgetBridge::reload);
		ClassDB::bind_method(D_METHOD("take_pending"), &WidgetBridge::take_pending);
	}

public:
	bool is_available() { return wb_is_available(); }
	bool write_snapshot(const String &json) { return wb_write_snapshot(json.utf8().get_data()); }
	void reload() { wb_reload(); }
	String take_pending() { return String::utf8(wb_take_pending().c_str()); }
};

static WidgetBridge *widgetbridge_singleton = nullptr;

void widgetbridge_init() {
	GDREGISTER_CLASS(WidgetBridge);
	widgetbridge_singleton = memnew(WidgetBridge);
	Engine::get_singleton()->add_singleton(Engine::Singleton("WidgetBridge", widgetbridge_singleton));
}

void widgetbridge_deinit() {
	if (widgetbridge_singleton != nullptr) {
		if (Engine::get_singleton() != nullptr) {
			Engine::get_singleton()->remove_singleton("WidgetBridge");
		}
		memdelete(widgetbridge_singleton);
		widgetbridge_singleton = nullptr;
	}
}
