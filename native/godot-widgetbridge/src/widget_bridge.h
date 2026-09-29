#pragma once
#include <string>

// Pure ObjC++ side (no Godot headers). Called from GodotPluginEntry.cpp.
bool wb_is_available();
bool wb_write_snapshot(const char *json);
void wb_reload();
std::string wb_take_pending();
