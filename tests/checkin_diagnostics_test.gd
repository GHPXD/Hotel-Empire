extends SceneTree

var failures: int = 0

func _initialize() -> void:
	var session := HotelSession.new(91)
	var reception := session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	var bedroom := session.hotel.build(HotelCatalog.room(&"bedroom"), 3, 0)
	bedroom.dirty = true
	session.hire(HotelSession.EMPLOYEES[0])
	var guest := session.spawn_guest()
	for tick in 250:
		session.tick(session.rules.tick)
		if CheckinDiagnostics.reason(session, reception) == "cleaning":
			break
	check(CheckinDiagnostics.reason(session, reception) == "cleaning", "staffed reception waits for dirty bedroom")
	check(session.guests.bookings == 0 and guest.state == &"checkin", "real admission blocked by cleaning")
	var before := SessionSnapshot.capture(session)
	var rows := HotelAnalytics.rooms(session, &"reception")
	check(rows[0].checkin_reason == "cleaning", "operations projection carries actual cause")
	check(preload("res://debug/checkin_metrics.gd").new().blocker(session, reception) == "cleaning", "benchmark uses same diagnosis")
	check(SessionSnapshot.capture(session) == before, "diagnostic does not mutate state or RNG")
	session.hire(HotelSession.EMPLOYEES[1])
	for tick in 400:
		session.tick(session.rules.tick)
		if session.guests.bookings > 0:
			break
	check(session.guests.bookings == 1 and bedroom.occupant == guest.id, "recommended cleaning intervention releases actual booking")
	check(CheckinDiagnostics.reason(session, reception) == "empty", "served queue no longer reports old blockage")
	var second := session.spawn_guest()
	for tick in 150:
		session.tick(session.rules.tick)
		if CheckinDiagnostics.reason(session, reception) == "occupied":
			break
	check(CheckinDiagnostics.reason(session, reception) == "occupied", "occupied bedroom distinguished from dirt")
	var free_room := session.hotel.build(HotelCatalog.room(&"bedroom"), 5, 0)
	check(free_room != null and CheckinDiagnostics.reason(session, reception) == "ready", "new clean room resolves occupancy diagnosis")
	session.tick(session.rules.tick)
	check(second.checked_in and session.guests.bookings == 2, "ready diagnosis agrees with next admission step")
	print(JSON.stringify({"suite": "checkin_diagnostics", "failures": failures}))
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
