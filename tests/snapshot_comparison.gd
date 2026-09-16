extends RefCounted

static func difference(a: Variant, b: Variant, path: String) -> String:
	if (a is int or a is float) and (b is int or b is float):
		# JSON decimal round trips may differ by ulps; discrete state must still match.
		return "" if absf(float(a) - float(b)) <= 0.00000001 else "%s: %s != %s" % [path, a, b]
	if typeof(a) != typeof(b):
		return path + ": type differs"
	if a is Dictionary:
		if a.size() != b.size():
			return path + ": key count differs"
		for key: Variant in a:
			if not b.has(key):
				return path + ": missing key " + str(key)
			var mismatch := difference(a[key], b[key], path + "." + str(key))
			if not mismatch.is_empty():
				return mismatch
		return ""
	if a is Array:
		if a.size() != b.size():
			return path + ": array size differs"
		for index in a.size():
			var mismatch := difference(a[index], b[index], path + "[%d]" % index)
			if not mismatch.is_empty():
				return mismatch
		return ""
	return "" if a == b else path + ": value differs"


