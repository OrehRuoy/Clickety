class_name CounterLogic
extends RefCounted


static func increment(project: Dictionary, counter_id: String, kind: String = "tap") -> Dictionary:
	var changed := {}
	var wrapped: Array = []
	var seen := {}
	_step(project, counter_id, seen, changed, wrapped)
	if changed.is_empty():
		return _result(changed, wrapped, false)
	_remember(project, changed, kind)
	return _result(changed, wrapped, false)


static func decrement(project: Dictionary, counter_id: String) -> Dictionary:
	var counter := _find(project, counter_id)
	if counter.is_empty() or not _can_decrement(counter):
		return _result({}, [], true)
	var changed := {}
	var wrapped: Array = []
	var seen := {}
	_unstep(project, counter_id, seen, changed)
	if changed.is_empty():
		return _result({}, [], true)
	_remember(project, changed, "minus")
	return _result(changed, wrapped, false)


static func set_value(project: Dictionary, counter_id: String, value: int) -> Dictionary:
	return _assign(project, counter_id, value, "edit")


static func reset(project: Dictionary, counter_id: String) -> Dictionary:
	var counter := _find(project, counter_id)
	if counter.is_empty():
		return _result({}, [], false)
	return _assign(project, counter_id, int(counter.get("start", 0)), "reset")


static func undo(project: Dictionary) -> Dictionary:
	var stack: Array = project.get("undo", [])
	if stack.is_empty():
		return _result({}, [], true)
	var entry: Dictionary = stack.pop_back()
	project["undo"] = stack
	var before: Dictionary = entry.get("before", {})
	var changed := {}
	for id in before:
		var counter := _find(project, str(id))
		if counter.is_empty():
			continue
		var old := int(counter.get("value", 0))
		var new_value := int(before[id])
		counter["value"] = new_value
		changed[str(id)] = [old, new_value]
	_push_history(project, changed, "undo")
	return _result(changed, [], false)


static func validate_links(project: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var counters: Array = project.get("counters", [])
	var ids := {}
	for counter in counters:
		ids[str(counter.get("id", ""))] = counter
	for counter in counters:
		var link = counter.get("link", {})
		if typeof(link) != TYPE_DICTIONARY or link.is_empty():
			continue
		var source := str(counter.get("id", ""))
		var target := str(link.get("to", ""))
		var on := str(link.get("on", ""))
		if target == "":
			continue
		if target == source:
			errors.append("self-link: %s" % source)
			continue
		if not ids.has(target):
			errors.append("missing target: %s" % target)
			continue
		if on == "wrap" and int(ids[target].get("reset_at", 0)) == 0:
			errors.append("wrap-link to counter with reset_at 0: %s" % target)
	if _has_loop(project):
		errors.append("loop")
	return errors


static func summary(project: Dictionary) -> Dictionary:
	var main: Dictionary = {}
	var secondary: Array = []
	for counter in project.get("counters", []):
		if main.is_empty() and str(counter.get("role", "")) == "main":
			main = counter
			continue
		secondary.append({
			"name": str(counter.get("name", "")),
			"value": int(counter.get("value", 0)),
			"reset_at": int(counter.get("reset_at", 0)),
		})
	return {
		"main_name": str(main.get("name", "")),
		"main_value": int(main.get("value", 0)),
		"target": int(project.get("target", 0)),
		"secondary": secondary,
	}


static func _assign(project: Dictionary, counter_id: String, value: int, kind: String) -> Dictionary:
	var counter := _find(project, counter_id)
	if counter.is_empty():
		return _result({}, [], false)
	var before := int(counter.get("value", 0))
	if before == value:
		return _result({}, [], false)
	counter["value"] = value
	var changed := {counter_id: [before, value]}
	_remember(project, changed, kind)
	return _result(changed, [], false)


static func _step(project: Dictionary, counter_id: String, seen: Dictionary, changed: Dictionary, wrapped: Array) -> void:
	if seen.has(counter_id):
		return
	var counter := _find(project, counter_id)
	if counter.is_empty():
		return
	seen[counter_id] = true
	var before := int(counter.get("value", 0))
	var after := before + int(counter.get("step", 1))
	var did_wrap := false
	var reset_at := int(counter.get("reset_at", 0))
	if reset_at > 0 and after > reset_at:
		after = int(counter.get("start", 0))
		did_wrap = true
	counter["value"] = after
	changed[counter_id] = [before, after]
	if did_wrap:
		wrapped.append(counter_id)
	for follower in _followers(project, counter_id, "step"):
		_step(project, str(follower.get("id", "")), seen, changed, wrapped)
	if did_wrap:
		for follower in _followers(project, counter_id, "wrap"):
			_step(project, str(follower.get("id", "")), seen, changed, wrapped)


static func _unstep(project: Dictionary, counter_id: String, seen: Dictionary, changed: Dictionary) -> void:
	if seen.has(counter_id):
		return
	var counter := _find(project, counter_id)
	if counter.is_empty() or not _can_decrement(counter):
		seen[counter_id] = true
		return
	seen[counter_id] = true
	var before := int(counter.get("value", 0))
	var start := int(counter.get("start", 0))
	var reset_at := int(counter.get("reset_at", 0))
	var after := before - int(counter.get("step", 1))
	var unwrapped := false
	if reset_at > 0 and before == start:
		after = reset_at
		unwrapped = true
	counter["value"] = after
	changed[counter_id] = [before, after]
	for follower in _followers(project, counter_id, "step"):
		_unstep(project, str(follower.get("id", "")), seen, changed)
	if unwrapped:
		for follower in _followers(project, counter_id, "wrap"):
			_unstep(project, str(follower.get("id", "")), seen, changed)


static func _can_decrement(counter: Dictionary) -> bool:
	var value := int(counter.get("value", 0))
	var start := int(counter.get("start", 0))
	var reset_at := int(counter.get("reset_at", 0))
	if reset_at > 0 and value == start:
		return true
	return value - int(counter.get("step", 1)) >= start


static func _remember(project: Dictionary, changed: Dictionary, kind: String) -> void:
	var before := {}
	for id in changed:
		before[id] = changed[id][0]
	var stack: Array = project.get("undo", [])
	stack.append({
		"t": int(Time.get_unix_time_from_system()),
		"before": before,
	})
	while stack.size() > Schema.UNDO_CAP:
		stack.pop_front()
	project["undo"] = stack
	_push_history(project, changed, kind)


static func _push_history(project: Dictionary, changed: Dictionary, kind: String) -> void:
	var history: Array = project.get("history", [])
	var now := int(Time.get_unix_time_from_system())
	for id in changed:
		var before: int = int(changed[id][0])
		var after: int = int(changed[id][1])
		history.append({
			"t": now,
			"c": id,
			"d": after - before,
			"v": after,
			"k": kind,
		})
	while history.size() > Schema.HISTORY_CAP:
		history.pop_front()
	project["history"] = history


static func _followers(project: Dictionary, source_id: String, on: String) -> Array:
	var found: Array = []
	for counter in project.get("counters", []):
		var link = counter.get("link", {})
		if typeof(link) != TYPE_DICTIONARY:
			continue
		if str(link.get("to", "")) == source_id and str(link.get("on", "")) == on:
			found.append(counter)
	return found


static func _find(project: Dictionary, counter_id: String) -> Dictionary:
	for counter in project.get("counters", []):
		if str(counter.get("id", "")) == counter_id:
			return counter
	return {}


static func _has_loop(project: Dictionary) -> bool:
	var seen := {}
	for counter in project.get("counters", []):
		var source := str(counter.get("id", ""))
		if _walk(project, source, {}, seen):
			return true
	return false


static func _walk(project: Dictionary, counter_id: String, stack: Dictionary, seen: Dictionary) -> bool:
	if stack.has(counter_id):
		return true
	if seen.has(counter_id):
		return false
	seen[counter_id] = true
	stack[counter_id] = true
	var counter := _find(project, counter_id)
	var link = counter.get("link", {})
	var looped := false
	if typeof(link) == TYPE_DICTIONARY:
		var target := str(link.get("to", ""))
		if target != "" and target != counter_id:
			looped = _walk(project, target, stack, seen)
	stack.erase(counter_id)
	return looped


static func _result(changed: Dictionary, wrapped: Array, blocked: bool) -> Dictionary:
	return {"changed": changed, "wrapped": wrapped, "blocked": blocked}
