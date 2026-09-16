extends SceneTree

var failures: int = 0

func _initialize() -> void:
	_test_unlocks_and_choices()
	_test_services()
	_test_calendar()
	_test_migration()
	_test_mixed_operation()
	print(JSON.stringify({"suite": "content", "failures": failures}))
	quit(1 if failures else 0)

func unlock(session: HotelSession) -> void:
	session.progression.evaluate({"bookings": 10, "meals": 5, "cleaned": 5})

func _test_unlocks_and_choices() -> void:
	var session := HotelSession.new()
	var cafe := HotelCatalog.room(&"cafe")
	var before := SessionSnapshot.capture(session)
	check(session.hotel.build(cafe, 0, 0) == null and SessionSnapshot.capture(session) == before, "locked construction has no side effects")
	session.progression.legacy_access = true
	check(session.hotel.build(cafe, 0, 0) == null, "legacy access does not grant future content")
	unlock(session)
	var snack := session.hotel.build(cafe, 0, 0)
	var meal := session.hotel.build(HotelCatalog.room(&"restaurant"), 3, 0)
	var lounge := session.hotel.build(HotelCatalog.room(&"lounge"), 8, 0)
	check(snack != null and lounge != null, "unlocked service construction")
	var selected: Dictionary = {}
	for profile in HotelCatalog.GUESTS:
		var actor := session.spawn_guest()
		actor.archetype_id = profile.id
		actor.state = &"deciding"
		actor.x = 2.75
		actor.needs = {"hunger": 44.0, "energy": 0.0, "entertainment": 40.0, "comfort": 0.0}
		session.guests._choose(actor, session.hotel, session.transport)
		selected[profile.id] = actor.target_room
	check(selected[&"balanced"] == meal.id and selected[&"business"] == snack.id and selected[&"leisure"] == lounge.id, "same situation produces meaningful profile choices")
	var hungry := session.spawn_guest()
	hungry.archetype_id = &"business"
	hungry.state = &"deciding"
	hungry.x = 2.75
	hungry.needs = {"hunger": 90.0, "energy": 0.0, "entertainment": 0.0, "comfort": 0.0}
	session.guests._choose(hungry, session.hotel, session.transport)
	check(hungry.target_room == meal.id, "meal beats snack at high hunger")
	hungry.money = 0
	session.guests._choose(hungry, session.hotel, session.transport)
	check(hungry.destination_state == &"exit", "unaffordable services excluded")

func _test_services() -> void:
	for id in [&"cafe", &"lounge"]:
		var session := HotelSession.new()
		unlock(session)
		var room := session.hotel.build(HotelCatalog.room(id), 0, 0)
		var actor := session.spawn_guest()
		actor.archetype_id = &"balanced"
		actor.target_room = room.id
		actor.state = &"service_queue"
		actor.needs[String(room.definition().need)] = 90.0
		var cash: int = actor.money
		for tick in 150:
			session.tick(0.1)
			if actor.service_uses > 0:
				break
		check(actor.service_uses == 1 and session.guests.service_uses == 1, "new service completes once")
		check(actor.money == cash - room.price() and room.income == room.price() and session.economy.revenue == room.price(), "new service payment reconciles")
		check(actor.needs[String(room.definition().need)] < 65.0, "new service relieves correct need")
		check(session.guests.meals_served == (1 if id == &"cafe" else 0), "leisure does not increment meal objective")
		check(SessionSnapshot.restore(SessionSnapshot.capture(session)).error.is_empty(), "new service snapshot")
	var session := HotelSession.new()
	unlock(session)
	var lounge := session.hotel.build(HotelCatalog.room(&"lounge"), 0, 0)
	for index in 5:
		var actor := session.spawn_guest()
		actor.target_room = lounge.id
		actor.state = &"service_queue"
	session.tick(0.1)
	check(lounge.users.size() == 3 and lounge.queue.members.size() == 2, "lounge capacity and waiting queue")
	var original := SessionSnapshot.capture(session)
	var restored := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(original)))
	check(restored.error.is_empty(), "new content in-flight snapshot")
	if restored.session != null:
		for tick in 1500:
			session.tick(0.1)
			restored.session.tick(0.1)
		check(preload("res://tests/snapshot_comparison.gd").difference(SessionSnapshot.capture(session), SessionSnapshot.capture(restored.session), "content").is_empty(), "new services continue identically")

func _test_calendar() -> void:
	var rules := SimulationRules.new()
	check(not HotelEvents.state(3599, rules).active, "event not early")
	check(HotelEvents.state(3600, rules).active and HotelEvents.state(3600, rules).multiplier == 1.5, "fair starts exactly")
	check(HotelEvents.state(4799, rules).active and not HotelEvents.state(4800, rules).active, "fair duration boundary")
	check(HotelEvents.state(7200, rules).id == &"quiet_season" and HotelEvents.state(7200, rules).multiplier == 0.65, "quiet event alternates")
	check(not HotelEvents.state(8400, rules).active and HotelEvents.state(10800, rules).id == &"local_fair", "cycle repeats without overlap")
	var counts: Array[int] = []
	for start in [1200, 3600, 7200]:
		var session := HotelSession.new(42)
		session.tick_count = start
		session.time = start * rules.tick
		session.day = floori(session.time / rules.day_seconds)
		session.opened = true
		for tick in 300:
			session.tick(0.1)
		counts.append(session.next_actor_id - 1)
	check(counts[1] > counts[0] and counts[2] < counts[0], "event modifiers change actual arrivals")
	var session := HotelSession.new(17)
	for tick in 3650:
		session.tick(0.1)
	var result := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(SessionSnapshot.capture(session))))
	check(result.error.is_empty(), "active event loads")
	if result.session != null:
		check(HotelEvents.state(session.tick_count, rules) == HotelEvents.state(result.session.tick_count, rules), "event phase retained")
		for tick in 5000:
			session.tick(0.1)
			result.session.tick(0.1)
		check(preload("res://tests/snapshot_comparison.gd").difference(SessionSnapshot.capture(session), SessionSnapshot.capture(result.session), "events").is_empty(), "continuity across event end and next event")
	check(session.actors.is_empty(), "closed hotel ignores event arrivals")
	print(JSON.stringify({"scenario": "event_arrivals_30_seconds", "normal": counts[0], "fair": counts[1], "quiet": counts[2]}))

func _test_migration() -> void:
	var old: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/m4-save-v3.json"))
	var before: Dictionary = old.duplicate(true)
	var result := SessionSnapshot.restore(old)
	check(result.error.is_empty() and old == before, "real M4 migration leaves input unchanged")
	if result.session == null:
		return
	for actor: ActorState in result.session.actors.values():
		check(actor.archetype_id == &"balanced" and actor.service_uses == actor.meals, "legacy profiles and service counters")
	var snapshot := SessionSnapshot.capture(result.session)
	var broken := snapshot.duplicate(true)
	broken.actors[0].archetype_id = "missing"
	check(not SessionSnapshot.restore(broken).error.is_empty(), "unknown profile rejected")
	broken = snapshot.duplicate(true)
	broken.actors[0].service_uses = -1
	check(not SessionSnapshot.restore(broken).error.is_empty(), "invalid usage rejected")
	broken = snapshot.duplicate(true)
	broken.guests.service_uses = -1
	check(not SessionSnapshot.restore(broken).error.is_empty(), "invalid aggregate usage rejected")
	for tick in 600:
		result.session.tick(0.1)
	check(SessionSnapshot.restore(SessionSnapshot.capture(result.session)).error.is_empty(), "migrated session continues and resaves")

func _test_mixed_operation() -> void:
	for seed_value in [1, 17, 123]:
		var session := SimulationRunner.make_hotel(seed_value, "standard", 250000)
		session.opened = true
		for tick in 2400:
			session.tick(0.1)
		check(session.progression.completed.has(&"steady_service"), "natural new-content unlock")
		session.hotel.add_floor(session.time)
		var cafe := session.hotel.build(HotelCatalog.room(&"cafe"), 13, 1, session.time)
		var lounge := session.hotel.build(HotelCatalog.room(&"lounge"), 3, 3, session.time)
		if cafe == null or lounge == null:
			check(false, "new content built in natural run")
			continue
		# Control demand after expansion: one new guest every 20 simulated seconds.
		# The continuous-arrival pressure scenario remains covered by stress_test.
		session.opened = false
		for tick in 7200:
			if tick % 200 == 0:
				session.spawn_guest()
			session.tick(0.1)
			if tick % 100 == 0:
				check(SimulationRunner.invariant_error(session, 250000).is_empty(), "mixed content invariants")
		check(cafe.income > 0 and lounge.income > 0, "both new services used in mixed simulation")
		check(SessionSnapshot.restore(SessionSnapshot.capture(session)).error.is_empty(), "mixed-content session saves")
		print(JSON.stringify({"scenario": "mixed_content", "seed": seed_value, "cafe_income": cafe.income, "lounge_income": lounge.income, "services": session.guests.service_uses, "meals": session.guests.meals_served, "cash": session.economy.cash}))

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
