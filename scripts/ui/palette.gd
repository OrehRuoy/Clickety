class_name Palette
extends Object

const THEMES := {
	"warm": {
		"bg": "#FBF6EE",
		"surface": "#FFFFFF",
		"ink": "#1E1B18",
		"muted": "#5E564E",
		"accent": "#B4492E",
		"accent_ink": "#FFFFFF",
	},
	"night": {
		"bg": "#161412",
		"surface": "#221F1C",
		"ink": "#F3ECE2",
		"muted": "#B8AEA2",
		"accent": "#E58A6B",
		"accent_ink": "#161412",
	},
	"contrast": {
		"bg": "#000000",
		"surface": "#000000",
		"ink": "#FFFFFF",
		"muted": "#FFFFFF",
		"accent": "#FFD400",
		"accent_ink": "#000000",
	},
}

const CHIPS: Array = [
	{"color": "#E69F00", "letter": "A", "shape": "circle"},
	{"color": "#56B4E9", "letter": "B", "shape": "square"},
	{"color": "#009E73", "letter": "C", "shape": "triangle"},
	{"color": "#CC79A7", "letter": "D", "shape": "diamond"},
	{"color": "#0072B2", "letter": "E", "shape": "bar"},
	{"color": "#D55E00", "letter": "F", "shape": "plus"},
]


static func colors(theme_name: String = "warm") -> Dictionary:
	var key := theme_name if THEMES.has(theme_name) else "warm"
	var raw: Dictionary = THEMES[key]
	var out := {}
	for entry in raw.keys():
		out[entry] = Color(str(raw[entry]))
	return out


static func chip(index: int) -> Dictionary:
	var item: Dictionary = CHIPS[posmod(index, CHIPS.size())]
	return {
		"color": Color(str(item["color"])),
		"letter": str(item["letter"]),
		"shape": str(item["shape"]),
	}
