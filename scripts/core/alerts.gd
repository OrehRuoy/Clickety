class_name Alerts
extends RefCounted


static func hits(project: Dictionary, result: Dictionary) -> Array:
	var changed = result.get("changed", {})
	if typeof(changed) != TYPE_DICTIONARY:
		return []
	var alerts = project.get("alerts", [])
	if typeof(alerts) != TYPE_ARRAY:
		return []
	var found: Array = []
	for alert in alerts:
		if typeof(alert) != TYPE_DICTIONARY:
			continue
		var counter_id := str(alert.get("counter_id", ""))
		if not changed.has(counter_id):
			continue
		var pair = changed[counter_id]
		if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
			continue
		var before := int(pair[0])
		var after := int(pair[1])
		if after <= before:
			continue
		var kind := str(alert.get("kind", ""))
		if kind == "at":
			if bool(alert.get("done", false)):
				continue
			if after == int(alert.get("row", -1)):
				alert["done"] = true
				found.append(alert)
		elif kind == "every":
			var every := int(alert.get("every", 0))
			var start_after := int(alert.get("from", 0))
			if every > 0 and after >= start_after and after != start_after and (after - start_after) % every == 0:
				found.append(alert)
	return found
