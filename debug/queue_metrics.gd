extends RefCounted
## Observational only. Includes both served and abandoned completed queue episodes.

var pending: Dictionary = {}
var totals: Dictionary = {"checkin": 0.0, "service_queue": 0.0}
var counts: Dictionary = {"checkin": 0, "service_queue": 0}
var maxima: Dictionary = {"checkin": 0.0, "service_queue": 0.0}
var previous_using: Dictionary = {}

func observe(session: HotelSession) -> void:
	var completed_now: Dictionary = {}
	for id: int in pending.keys():
		var actor: ActorState = session.actors.get(id)
		var record: Dictionary = pending[id]
		if actor == null or String(actor.state) != record.state or actor.target_room != record.room:
			var duration: float = (session.tick_count - int(record.tick)) * session.rules.tick
			totals[record.state] += duration
			counts[record.state] += 1
			maxima[record.state] = maxf(maxima[record.state], duration)
			completed_now[id] = true
			pending.erase(id)
	var current_using: Dictionary = {}
	for actor: ActorState in session.actors.values():
		if actor.role == &"guest" and actor.state == &"using":
			current_using[actor.id] = true
			# Arrival and immediate admission can occur inside one simulation tick.
			if not previous_using.has(actor.id) and not completed_now.has(actor.id):
				counts.service_queue += 1
		if actor.role == &"guest" and String(actor.state) in totals and not pending.has(actor.id):
			pending[actor.id] = {"state": String(actor.state), "room": actor.target_room, "tick": session.tick_count}
	previous_using = current_using

func summary() -> Dictionary:
	var result: Dictionary = {}
	for state: String in totals:
		result[state] = {"completed_episodes": counts[state], "mean_seconds": totals[state] / maxi(1, counts[state]), "max_seconds": maxima[state]}
	result["unfinished_episodes"] = pending.size()
	return result
