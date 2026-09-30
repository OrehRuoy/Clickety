extends SceneTree

const BODY := 4.5
const LARGE := 3.0


func _init() -> void:
	var message := run()
	quit(0 if message == "PASS" else 1)


static func run() -> String:
	var failed := false
	for theme_name in ["warm", "night", "contrast"]:
		var palette: Dictionary = Palette.colors(theme_name)
		var pairs := [
			["ink", "bg", BODY, "body"],
			["ink", "surface", BODY, "body"],
			["muted", "bg", BODY, "body"],
			["muted", "surface", BODY, "body"],
			["accent", "bg", BODY, "body"],
			["accent_ink", "accent", BODY, "body"],
			["ink", "bg", LARGE, "numeral"],
		]
		for pair in pairs:
			var fg: Color = palette[pair[0]]
			var bg: Color = palette[pair[1]]
			var minimum := float(pair[2])
			var value := Palette.ratio(fg, bg)
			var ok := value + 0.001 >= minimum
			if not ok:
				failed = true
			print("%s  %-12s  %s on %-8s  %5.2f  %s" % [
				"PASS" if ok else "FAIL",
				pair[3],
				pair[0],
				pair[1],
				value,
				theme_name,
			])
	for index in Palette.CHIPS.size():
		var chip: Dictionary = Palette.chip(index)
		var ink := Palette.chip_ink(index)
		var value := Palette.ratio(ink, chip["color"])
		var ok := value + 0.001 >= BODY
		if not ok:
			failed = true
		print("%s  %-12s  letter %s on chip   %5.2f" % [
			"PASS" if ok else "FAIL",
			"body",
			chip["letter"],
			value,
		])
	var summary := "PASS" if not failed else "FAIL"
	print(summary)
	return summary
