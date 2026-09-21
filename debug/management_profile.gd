extends SceneTree
## Observational M9 comparison: unchanged rules, real purchases and natural arrivals.

var failures: int = 0

func _initialize() -> void:
	var reports: Array[Dictionary] = []
	for policy: String in ["static", "services", "capacity", "combined"]:
		for seed_value: int in [1, 17, 123]:
			reports.append(run_case(seed_value, policy))
	var file := FileAccess.open("res://.runtime/m9-management.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"days": 30, "reserve": 1000, "failures": failures, "reports": reports}, "\t"))
	file.close()
	print(JSON.stringify({"suite": "management_profile", "failures": failures, "scenarios": reports.size()}))
	quit(1 if failures else 0)

func run_case(seed_value: int, policy: String) -> Dictionary:
	var session := HotelSession.new(seed_value)
	var starting_cash: int = session.economy.cash
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 3, 0)
	var lift := session.hotel.build(HotelCatalog.room(&"elevator"), 6, 0)
	for level: int in [1, 2]:
		session.hotel.add_floor()
		for column: int in [0, 2, 4, 8]:
			session.hotel.build(HotelCatalog.room(&"bedroom"), column, level)
	for employee: EmployeeDefinition in HotelSession.EMPLOYEES:
		session.hire(employee)
	if session.hotel.rooms.size() != 11 or session.actors.size() != 2:
		failures += 1
		return {"error": "invalid starting fixture"}
	var actions: Array[Dictionary] = []
	if policy in ["services", "combined"]:
		actions.append({"kind": "build", "room": &"cafe", "column": 7, "floor": 0})
		actions.append({"kind": "build", "room": &"lounge", "column": 9, "floor": 0})
	if policy in ["capacity", "combined"]:
		actions.append({"kind": "hire"})
		actions.append({"kind": "upgrade", "id": lift.id})
		for level: int in [1, 2]:
			for column: int in [10, 12]:
				actions.append({"kind": "build", "room": &"bedroom", "column": column, "floor": level})
	var purchases: Array[Dictionary] = []
	var queues := preload("res://debug/queue_metrics.gd").new()
	var minimum_cash: int = session.economy.cash
	var state_samples: Dictionary = {}
	var objective_ticks: Dictionary = {}
	session.opened = true
	for index: int in range(1, 36001):
		# One planned investment per game day from day 5; retry if locked/unaffordable.
		if index >= 6000 and index % 1200 == 0 and not actions.is_empty():
			var before: int = session.economy.cash
			if purchase(session, actions[0]):
				var action: Dictionary = actions.pop_front()
				action["tick"] = index
				action["cost"] = before - session.economy.cash
				purchases.append(action)
		session.tick(session.rules.tick)
		queues.observe(session)
		minimum_cash = mini(minimum_cash, session.economy.cash)
		for id: StringName in session.progression.completed:
			if not objective_ticks.has(id):
				objective_ticks[id] = index
		if index % 100 == 0:
			for actor: ActorState in session.actors.values():
				if actor.role == &"guest":
					state_samples[actor.state] = int(state_samples.get(actor.state, 0)) + 1
			var error := SimulationRunner.invariant_error(session, starting_cash)
			if not error.is_empty():
				failures += 1
				push_error(error)
				break
	if minimum_cash < 0 or not actions.is_empty():
		failures += 1
		push_error("Policy insolvent or unfinished: %s / %d" % [policy, seed_value])
	var report: Dictionary = {"policy": policy, "seed": seed_value, "ticks": session.tick_count, "minimum_cash": minimum_cash, "ending_cash": session.economy.cash, "bookings": session.guests.bookings, "meals": session.guests.meals_served, "cleaned": session.employees.cleaned, "departures": session.guests.completed, "reputation": session.guests.reputation, "queues": queues.summary(), "guest_state_samples": state_samples, "purchases": purchases, "objective_ticks": objective_ticks}
	print(JSON.stringify(report))
	return report

func purchase(session: HotelSession, action: Dictionary) -> bool:
	var available: int = session.economy.cash - 1000
	match action.kind:
		"build":
			var definition := HotelCatalog.room(action.room)
			if available < definition.build_cost:
				return false
			return session.hotel.build(definition, action.column, action.floor) != null
		"hire":
			var definition: EmployeeDefinition = HotelSession.EMPLOYEES[1]
			return available >= definition.hire_cost and session.hire(definition).is_empty()
		"upgrade":
			var room := session.hotel.by_id(action.id)
			return available >= room.next_upgrade().cost and session.upgrade_room(room.id).is_empty()
	return false
