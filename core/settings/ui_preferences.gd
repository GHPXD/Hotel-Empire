class_name UIPreferences
extends RefCounted
## Device preference, deliberately separate from hotel snapshots.

const PATH: String = "user://interface.cfg"

static func load_large_text(path: String = PATH) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return false
	var value: Variant = config.get_value("interface", "large_text", false)
	return value if value is bool else false

static func save_large_text(value: bool, path: String = PATH) -> Error:
	var config := ConfigFile.new()
	config.set_value("interface", "large_text", value)
	return config.save(path)
