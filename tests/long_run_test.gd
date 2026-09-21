extends SceneTree
## M9: real starting budget, natural arrivals, 30 days and periodic save continuity.

var failures: int = 0

func _initialize() -> void:
	var reports: Array[Dictionary] = []
	for bedrooms in [2, 8]:
		for seed_value in [1, 17, 123]:
			reports.append(run_case(seed_value, bedrooms))
	var file := FileAccess.open("res://.runtime/m9-long-run.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"days": 30, "reports": reports, "failures": failures}, "\t"))
	file.close()
	print(JSON.stringify({"suite": "long_run", "failures": failures, "scenarios": reports.size()}))
	quit(1 if failures else 0)

func run_case(seed_value: int, bedrooms: int) -> Dictionary:
	var session := HotelSession.new(seed_value)
	var starting_cash: int = session.economy.cash
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 3, 0)
	session.hotel.build(HotelCatalog.room(&"elevator"), 6, 0)
	for level in range(1, 2 if bedrooms == 2 else 3):
		session.hotel.add_floor()
		for column in ([0, 2] if bedrooms == 2 else [0, 2, 4, 8]):
			session.hotel.build(HotelCatalog.room(&"bedroom"), column, level)
	for employee in HotelSession.EMPLOYEES:
		session.hire(employee)
	var fixture_valid: bool = session.hotel.rooms.size() == bedrooms + 3 and session.actors.size() == 2
	check(fixture_valid, "starting budget funds fixture")
	if not fixture_valid:
		return {"seed": seed_value, "bedrooms": bedrooms, "error": "fixture construction failed"}
	session.opened = true
	var shadow: HotelSession
	var shadow_ticks: int = 0
	var checkpoints: int = 0
	var minimum_cash: int = session.economy.cash
	var peak_guests: int = 0
	var objective_ticks: Dictionary = {}
	for index in range(1, 36001):
		session.tick(session.rules.tick)
		if shadow != null:
			shadow.tick(shadow.rules.tick)
			shadow_ticks -= 1
			if shadow_ticks == 0:
				compare(session, shadow, "continued save")
				session = shadow
				shadow = null
				checkpoints += 1
		minimum_cash = mini(minimum_cash, session.economy.cash)
		for id: StringName in session.progression.completed:
			if not objective_ticks.has(id):
				objective_ticks[id] = index
		if index % 100 == 0:
			peak_guests = maxi(peak_guests, session.guest_count())
			var error := SimulationRunner.invariant_error(session, starting_cash)
			check(error.is_empty(), "seed %d day %.1f: %s" % [seed_value, session.time / 120, error])
			if not error.is_empty():
				break
		if index % 6000 == 0 and index < 36000:
			var loaded := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(SessionSnapshot.capture(session))))
			check(loaded.error.is_empty(), "long run save restores")
			if loaded.error.is_empty():
				shadow = loaded.session
				shadow_ticks = 120
				compare(session, shadow, "restored save")
	check(checkpoints == 5, "five saves continue identically")
	check(session.guests.bookings > 0 and session.guests.meals_served > 0 and session.employees.cleaned > 0, "productive long-running hotel")
	if bedrooms == 8:
		check(minimum_cash >= 0, "reference hotel stays solvent with starting budget")
		check(int(objective_ticks.get(&"steady_service", 36001)) <= 6000, "reference hotel unlocks services within five days")
	var report: Dictionary = {"seed": seed_value, "bedrooms": bedrooms, "starting_cash": starting_cash, "minimum_cash": minimum_cash, "ending_cash": session.economy.cash, "bookings": session.guests.bookings, "meals": session.guests.meals_served, "cleaned": session.employees.cleaned, "departures": session.guests.completed, "reputation": session.guests.reputation, "peak_guests_sampled": peak_guests, "save_checkpoints": checkpoints, "objective_ticks": objective_ticks, "ticks": session.tick_count}
	print(JSON.stringify(report))
	return report

func compare(left: HotelSession, right: HotelSession, label: String) -> void:
	var mismatch := preload("res://tests/snapshot_comparison.gd").difference(SessionSnapshot.capture(left), SessionSnapshot.capture(right), label)
	check(mismatch.is_empty(), mismatch)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
