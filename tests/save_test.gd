extends SceneTree

var failures: int = 0

func _initialize() -> void:
	var session := HotelSession.new(555)
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 4, 0)
	session.hotel.add_floor()
	for column in [0, 2, 4]:
		session.hotel.build(HotelCatalog.room(&"bedroom"), column, 1)
	session.hotel.build(HotelCatalog.room(&"elevator"), 9, 0)
	session.hire(HotelSession.EMPLOYEES[0])
	session.hire(HotelSession.EMPLOYEES[1])
	session.opened = true
	var transit_saved: bool = false
	for tick in 400:
		session.tick(0.1)
		if not session.transport.lifts[0].passengers.is_empty():
			transit_saved = true
			break
	check(transit_saved, "snapshot during elevator journey")
	var original := SessionSnapshot.capture(session)
	var encoded: String = JSON.stringify(original)
	var result := SessionSnapshot.restore(JSON.parse_string(encoded))
	check(result.error.is_empty(), "valid snapshot restores: " + result.error)
	if result.session == null:
		quit(1)
		return
	var restored: HotelSession = result.session
	check(JSON.stringify(SessionSnapshot.capture(restored)) == encoded, "all fields round trip")
	for tick in 2400:
		session.tick(0.1)
		restored.tick(0.1)
	check(JSON.stringify(SessionSnapshot.capture(session)) == JSON.stringify(SessionSnapshot.capture(restored)), "deterministic continuation after reload")
	var path: String = "user://save-regression.json"
	check(SaveStore.save_session(session, path).is_empty(), "disk write")
	check(SaveStore.save_session(session, path).is_empty(), "atomic replacement with backup")
	var loaded := SaveStore.load_session(path)
	check(loaded.error.is_empty(), "disk load")
	if loaded.session != null:
		check(JSON.stringify(SessionSnapshot.capture(loaded.session)) == JSON.stringify(SessionSnapshot.capture(session)), "disk state identical")
	check(not SaveStore.load_session("user://absent-regression.json").error.is_empty(), "missing file rejected")
	var broken := original.duplicate(true)
	broken.version = 99
	check(not SessionSnapshot.restore(broken).error.is_empty(), "unknown version rejected")
	broken = original.duplicate(true)
	broken.rooms[0].definition_id = "unknown"
	check(not SessionSnapshot.restore(broken).error.is_empty(), "unknown content rejected")
	broken = original.duplicate(true)
	broken.actors[0].needs.hunger = "oops"
	check(not SessionSnapshot.restore(broken).error.is_empty(), "invalid field type rejected")
	broken = original.duplicate(true)
	broken.lifts[0].passengers.append(99999)
	check(not SessionSnapshot.restore(broken).error.is_empty(), "dangling passenger rejected")
	broken = original.duplicate(true)
	broken.rooms[1].column = 0
	check(not SessionSnapshot.restore(broken).error.is_empty(), "overlap rejected")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{\"version\":1,")
	file.close()
	check(not SaveStore.load_session(path).error.is_empty(), "truncated save rejected")
	print(JSON.stringify({"suite": "save", "failures": failures, "completed": session.guests.completed}))
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
