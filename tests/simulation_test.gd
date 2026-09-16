extends SceneTree

var failures: int = 0

func _initialize() -> void:
	var session := make_hotel()
	var actor := session.spawn_guest()
	var saw_sleep: bool = false
	var saw_meal: bool = false
	var saw_riding: bool = false
	for tick in 1800:
		session.tick(0.1)
		saw_sleep = saw_sleep or actor.sleeps > 0
		saw_meal = saw_meal or actor.meals > 0
		saw_riding = saw_riding or actor.state == &"riding"
	check(actor.checked_in, "guest checked in")
	check(saw_sleep and saw_meal and saw_riding, "guest slept, ate and rode elevator")
	check(not session.actors.has(actor.id), "guest departed")
	check(session.guests.bookings == 1 and session.guests.meals_served > 0, "booking and food metrics")
	check(session.employees.cleaned == 1, "cleaner restores room")
	check(session.economy.revenue >= 168, "room and food revenue")
	check(session.economy.expenses > 0, "maintenance and salaries")
	check(session.transport.lifts[0].delivered >= 4, "vertical traffic")
	check(session.transport.lifts[0].queue.members.is_empty(), "queues drain")
	var without_staff := HotelSession.new()
	without_staff.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	without_staff.hotel.build(HotelCatalog.room(&"bedroom"), 4, 0)
	var impatient := without_staff.spawn_guest()
	for tick in 900:
		without_staff.tick(0.1)
	check(not impatient.checked_in and not without_staff.actors.has(impatient.id), "unstaffed reception times out")
	_test_elevator_capacity()
	print(JSON.stringify({"suite": "simulation", "failures": failures, "revenue": session.economy.revenue, "meals": session.guests.meals_served, "cleaned": session.employees.cleaned, "lift_delivered": session.transport.lifts[0].delivered}))
	quit(1 if failures else 0)

func make_hotel() -> HotelSession:
	var session := HotelSession.new(123)
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 4, 0)
	session.hotel.add_floor()
	session.hotel.build(HotelCatalog.room(&"bedroom"), 0, 1)
	session.hotel.build(HotelCatalog.room(&"elevator"), 8, 0)
	session.hire(HotelSession.EMPLOYEES[0])
	session.hire(HotelSession.EMPLOYEES[1])
	return session

func _test_elevator_capacity() -> void:
	var session := make_hotel()
	session.actors.clear()
	session.transport.sync(session.hotel)
	for id in 13:
		var actor := ActorState.new()
		actor.id = id
		actor.x = 8.5
		actor.travel_to(1.0, 1, &"idle")
		session.actors[id] = actor
	for tick in 1000:
		session.transport.step(session.actors, 0.1)
		check(session.transport.lifts[0].passengers.size() <= 4, "elevator never exceeds capacity")
	for actor: ActorState in session.actors.values():
		check(actor.floor_index == 1 and actor.state == &"idle", "all passengers reach destination")
	check(session.transport.lifts[0].delivered == 13, "exactly once delivery")
	check(session.transport.lifts[0].wait_max > 0, "waiting telemetry")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
