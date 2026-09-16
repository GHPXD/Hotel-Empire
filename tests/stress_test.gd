extends SceneTree

var failures: int = 0

func _initialize() -> void:
	for seed_value in [1, 17, 123, 555, 9001]:
		var report := SimulationRunner.run({"seed": seed_value, "days": 5, "guests": 0, "starting_money": 250000, "template": "standard"})
		if report.has("error"):
			check(false, str(report.error))
			continue
		check(not report.has("error") and report.get("failures", ["missing"]).is_empty(), "hotel seed %d: %s" % [seed_value, report.get("failures", report.get("error", ""))])
		check(report.bookings > 0 and report.meals > 0 and report.cleaned > 0, "productive loop across seeds")
		check(report.queues.checkin.completed_episodes > 0 and report.queues.checkin.mean_seconds >= 4.0, "check-in duration metrics")
		check(report.queues.service_queue.completed_episodes > 0, "service queue metrics")
		print(JSON.stringify(report))
	for count in [100, 250, 500, 1000]:
		_transport_stress(count)
	check(SimulationRunner.parse(["--simulate", "--days=0"]).has("error"), "invalid CLI duration")
	check(SimulationRunner.parse(["--simulate", "--guests=no"]).has("error"), "invalid CLI guests")
	check(SimulationRunner.make_hotel(1, "standard", 0) == null, "underfunded template rejected")
	print(JSON.stringify({"suite": "stress", "failures": failures}))
	quit(1 if failures else 0)

func _transport_stress(count: int) -> void:
	var session := HotelSession.new(123)
	session.economy.cash = 100000
	for floor_index in 3:
		session.hotel.add_floor()
	for column in [2, 6, 10, 14]:
		session.hotel.build(HotelCatalog.room(&"elevator"), column, 0)
	for id in range(1, count + 1):
		var actor := ActorState.new()
		actor.id = id
		actor.x = float(id % 16)
		actor.floor_index = id % 4
		actor.travel_to(float((id * 7) % 16), (actor.floor_index + 2) % 4, &"idle")
		session.actors[id] = actor
	var maximum_usec: int = 0
	var start_usec: int = Time.get_ticks_usec()
	for tick in 15000:
		var before: int = Time.get_ticks_usec()
		session.transport.step(session.actors, 0.1)
		maximum_usec = maxi(maximum_usec, Time.get_ticks_usec() - before)
		for lift in session.transport.lifts:
			check(lift.passengers.size() <= lift.capacity, "stress capacity")
		if tick % 100 == 0:
			var delivered: int = 0
			for lift in session.transport.lifts:
				delivered += lift.delivered
			if delivered == count:
				break
	for actor: ActorState in session.actors.values():
		check(actor.floor_index == actor.target_floor, "stress destination")
	var delivered: int = 0
	for lift in session.transport.lifts:
		delivered += lift.delivered
		check(lift.queue.members.is_empty() and lift.passengers.is_empty(), "stress queue drain")
	check(delivered == count, "stress exactly once delivery")
	print(JSON.stringify({"mode": "transport_only", "agents": count, "delivered": delivered, "total_ms": (Time.get_ticks_usec() - start_usec) / 1000.0, "max_step_ms": maximum_usec / 1000.0}))

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
