extends SceneTree

var failures: int = 0
var checkpoints: int = 0
var states: Dictionary = {}

func _initialize() -> void:
	for seed_value in [1, 17, 123, 555, 9001]:
		var baseline := SimulationRunner.make_hotel(seed_value, "standard", 250000)
		baseline.opened = true
		for delay in [100, 299, 777, 1201]:
			for tick in delay:
				baseline.tick(baseline.rules.tick)
			for actor: ActorState in baseline.actors.values():
				states[String(actor.state)] = true
			var restored := SessionSnapshot.restore(JSON.parse_string(JSON.stringify(SessionSnapshot.capture(baseline))))
			if not restored.error.is_empty():
				fail("seed %d tick %d: %s" % [seed_value, baseline.tick_count, restored.error])
				continue
			var copy: HotelSession = restored.session
			for tick in 600:
				baseline.tick(baseline.rules.tick)
				copy.tick(copy.rules.tick)
			var mismatch := preload("res://tests/snapshot_comparison.gd").difference(SessionSnapshot.capture(baseline), SessionSnapshot.capture(copy), "session")
			if not mismatch.is_empty():
				fail("seed %d tick %d: %s" % [seed_value, baseline.tick_count, mismatch])
			checkpoints += 1
	for state in ["riding", "checkin", "using", "walking", "cleaning", "lift_queue"]:
		if not states.has(state):
			fail("No checkpoint covered " + state)
	print(JSON.stringify({"suite": "save_multiseed", "checkpoints": checkpoints, "states": states.keys(), "failures": failures}))
	quit(1 if failures else 0)

func fail(message: String) -> void:
	failures += 1
	push_error(message)

