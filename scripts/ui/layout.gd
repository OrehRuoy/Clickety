class_name Layout
extends Object

const MAX_COLUMN_WIDTH := 600.0


static func column_width(viewport_width: float) -> float:
	return minf(viewport_width, MAX_COLUMN_WIDTH)
