extends SceneTree

var failures: int = 0

func _initialize() -> void:
	_test_thresholds()
	_test_save()
	_test_live_progression()
	print(JSON.stringify({"suite": "progression", "failures": failures}))
	quit(1 if failures else 0)

func _test_thresholds() -> void:
	var session := HotelSession.new()
	var bedroom := session.hotel.build(HotelCatalog.room(&"bedroom"), 0, 0)
	var lift := session.hotel.build(HotelCatalog.room(&"elevator"), 5, 0)
	check(session.upgrade_room(bedroom.id).is_empty(), "N2 available at start")
	var before := SessionSnapshot.capture(session)
	check(not session.upgrade_room(bedroom.id).is_empty(), "N3 locked through session command")
	check(SessionSnapshot.capture(session) == before, "locked purchase has no side effects")
	session.guests.bookings = 2
	session.tick(0.1)
	check(session.progression.completed.is_empty(), "below threshold")
	session.guests.bookings = 3
	session.tick(0.1)
	check(session.progression.completed == [&"first_stays"], "exact threshold completes first objective")
	check(session.upgrade_room(bedroom.id).is_empty(), "earned N3 purchase")
	check(session.upgrade_room(lift.id).is_empty(), "elevator N2 initially available")
	check(not session.upgrade_room(lift.id).is_empty(), "different reward still locked")
	session.guests.bookings = 10
	session.guests.meals_served = 5
	session.employees.cleaned = 4
	session.tick(0.1)
	check(session.progression.completed.size() == 1, "all conditions required")
	session.employees.cleaned = 5
	session.tick(0.1)
	check(session.upgrade_room(lift.id).is_empty(), "second objective unlocks elevator")
	session.guests.completed = 20
	session.guests.reputation = 64.9
	session.tick(0.1)
	check(session.progression.completed.size() == 2, "reputation below threshold")
	session.guests.reputation = 65
	session.tick(0.1)
	check(session.progression.completed.size() == 3, "reference title earned")
	session.guests.reputation = 20
	var cash: int = session.economy.cash
	for tick in 10:
		session.tick(0.1)
	check(session.progression.completed.size() == 3 and session.economy.cash == cash, "latched completions, no repeated cash rewards")
	check(HotelSession.new().progression.completed.is_empty(), "new run resets objectives")

func _test_save() -> void:
	var session := HotelSession.new()
	session.guests.bookings = 2
	session.tick(0.1)
	var snapshot := SessionSnapshot.capture(session)
	var result := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(snapshot)))
	check(result.error.is_empty(), "partial progress roundtrip")
	if result.session != null:
		result.session.guests.bookings = 3
		result.session.tick(0.1)
		check(result.session.progression.completed.size() == 1, "resumed run completes once")
		var completed := SessionSnapshot.capture(result.session)
		check(SessionSnapshot.restore(completed).error.is_empty(), "completed progress roundtrip")
	for invalid: Variant in [{}, {"completed": ["unknown"], "legacy_access": false}, {"completed": ["first_stays", "first_stays"], "legacy_access": false}, {"completed": ["steady_service"], "legacy_access": false}, {"completed": [], "legacy_access": 1}]:
		var broken := snapshot.duplicate(true)
		broken.progression = invalid
		check(not SessionSnapshot.restore(broken).error.is_empty(), "malformed progress rejected")
	var room := session.hotel.build(HotelCatalog.room(&"bedroom"), 0, 0)
	room.level = 3
	check(not SessionSnapshot.restore(SessionSnapshot.capture(session)).error.is_empty(), "unearned installed level rejected")
	var legacy := SessionSnapshot.capture(session)
	legacy.version = 2
	legacy.erase("progression")
	var original := legacy.duplicate(true)
	result = SessionSnapshot.restore(legacy)
	check(result.error.is_empty() and legacy == original, "v2 migration transactional")
	if result.session != null:
		check(result.session.progression.legacy_access and result.session.hotel.rooms[0].level == 3, "v2 installed level and access preserved")
		check(SessionSnapshot.restore(SessionSnapshot.capture(result.session)).error.is_empty(), "legacy entitlement persists in v3")
	var v1: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/m2-save-v1.json"))
	result = SessionSnapshot.restore(v1)
	check(result.error.is_empty() and result.session.progression.legacy_access, "v1 migrates through v2 to v3")
	var v2: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/m3-save-v2.json"))
	result = SessionSnapshot.restore(v2)
	check(result.error.is_empty() and result.session.progression.legacy_access, "real M3 fixture migrates")
	if result.session != null:
		for tick in 600:
			result.session.tick(0.1)
		check(SessionSnapshot.restore(SessionSnapshot.capture(result.session)).error.is_empty(), "real M3 session continues and resaves")

func _test_live_progression() -> void:
	var session := HotelSession.new(99)
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 3, 0)
	session.hotel.build(HotelCatalog.room(&"elevator"), 6, 0)
	session.hotel.add_floor()
	session.hotel.build(HotelCatalog.room(&"bedroom"), 0, 1)
	session.hotel.build(HotelCatalog.room(&"bedroom"), 2, 1)
	for employee in HotelSession.EMPLOYEES:
		session.hire(employee)
	# Sequential real guests avoid a demand burst masking progression feasibility.
	session.opened = false
	for visitor in 25:
		session.spawn_guest()
		for tick in 2500:
			session.tick(0.1)
			if session.guest_count() == 0:
				break
	check(session.progression.completed.size() == 3, "all objectives attainable through actual services")
	check(session.economy.cash > 0, "starting budget supports sequential progression without subsidy")
	var saved := SessionSnapshot.capture(session)
	var result := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(saved)))
	check(result.error.is_empty(), "earned progression loads")
	if result.session != null:
		for tick in 600:
			session.tick(0.1)
			result.session.tick(0.1)
		var mismatch: String = preload("res://tests/snapshot_comparison.gd").difference(SessionSnapshot.capture(session), SessionSnapshot.capture(result.session), "progression")
		check(mismatch.is_empty(), "progression continuity: " + mismatch)
	print(JSON.stringify({"scenario": "sequential_guests", "seed": 99, "starting_cash": 12000, "cash": session.economy.cash, "ticks": session.tick_count, "metrics": session.progression_metrics(), "objectives": session.progression.completed}))

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
