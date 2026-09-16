class_name HotelEvents
extends RefCounted
## Calendar derived solely from saved tick_count; no timers or RNG to drift on load.

const EVENTS: Array[EventDefinition] = [preload("res://data/events/local_fair.tres"), preload("res://data/events/quiet_season.tres")]

static func state(tick_count: int, rules: SimulationRules) -> Dictionary:
	var interval: int = roundi(rules.event_interval_days * rules.day_seconds / rules.tick)
	var cycle: int = floori(float(tick_count) / interval)
	var phase: int = tick_count % interval
	var current: EventDefinition = EVENTS[(maxi(1, cycle) - 1) % EVENTS.size()]
	var duration: int = roundi(current.duration_days * rules.day_seconds / rules.tick)
	if cycle > 0 and phase < duration:
		return {"id": current.id, "name": current.display_name, "description": current.description, "active": true, "multiplier": current.arrival_multiplier, "remaining": (duration - phase) * rules.tick}
	var next: EventDefinition = EVENTS[cycle % EVENTS.size()]
	return {"id": next.id, "name": next.display_name, "description": next.description, "active": false, "multiplier": 1.0, "remaining": (interval - phase) * rules.tick}
