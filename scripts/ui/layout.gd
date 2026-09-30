class_name Layout
extends Object

const MAX_COLUMN_WIDTH := 600.0


static func column_width(viewport_width: float) -> float:
	return minf(viewport_width, MAX_COLUMN_WIDTH)


static func fit_column(column: Control) -> void:
	if column == null or not is_instance_valid(column):
		return
	var parent := column.get_parent() as Control
	if parent == null:
		return
	var available := parent.size.x
	if available < 8.0:
		return
	var width := minf(available, MAX_COLUMN_WIDTH)
	column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if absf(column.custom_minimum_size.x - width) > 0.5:
		column.custom_minimum_size.x = width
