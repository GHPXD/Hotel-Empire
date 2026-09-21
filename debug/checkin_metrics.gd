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
	var head: ActorState = session.actors.get(reception.queue.members[0])
	if head == null:
		return "missing_head"
	if head.state != &"checkin":
		return "head_travelling"
	var staffed: bool = false
	for employee: ActorState in session.actors.values():
		if employee.role == &"receptionist" and employee.assignment == reception.id and employee.state == &"working":
			staffed = true
			break
	if not staffed:
		return "unstaffed"
	if head.timer + session.rules.tick + SimulationRules.TIME_EPSILON < reception.duration():
		return "processing"
	var dirty_free: bool = false
	var affordable_accessible: bool = false
	var accessible: bool = false
	for room: RoomState in session.hotel.rooms:
		if room.definition().category != &"lodging" or not session.transport.accessible(head.floor_index, room.floor_index):
			continue
		accessible = true
		if head.money < room.price():
			continue
		affordable_accessible = true
		if room.occupant < 0:
			if not room.dirty:
				return "ready"
			dirty_free = true
	if dirty_free:
		return "cleaning"
	if affordable_accessible:
		return "occupied"
	return "unaffordable" if accessible else "no_accessible_bedroom"
