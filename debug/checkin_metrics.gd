extends RefCounted
## Pre-tick observation. Assign all waiting guests to their queue head's blocker.
## Guest-seconds are accumulated exposure, not distinct visitors or latency percentiles.

var guest_seconds: Dictionary = {}

func observe(session: HotelSession) -> void:
	for room: RoomState in session.hotel.rooms:
		if room.definition().category != &"reception" or room.queue.members.is_empty():
			continue
		var waiting: int = 0
		for id: int in room.queue.members:
			var actor: ActorState = session.actors.get(id)
			if actor != null and actor.state == &"checkin":
				waiting += 1
		var reason := blocker(session, room)
		guest_seconds[reason] = float(guest_seconds.get(reason, 0.0)) + waiting * session.rules.tick

func blocker(session: HotelSession, reception: RoomState) -> String:
	return CheckinDiagnostics.reason(session, reception)
