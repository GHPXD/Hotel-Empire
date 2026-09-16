class_name HotelCatalog
extends RefCounted

const ROOMS: Array[RoomDefinition] = [
	preload("res://data/rooms/reception.tres"),
	preload("res://data/rooms/bedroom.tres"),
	preload("res://data/rooms/restaurant.tres"),
	preload("res://data/rooms/elevator.tres"),
	preload("res://data/rooms/cafe.tres"),
	preload("res://data/rooms/lounge.tres"),
]

const GUESTS: Array[GuestArchetype] = [preload("res://data/guests/balanced.tres"), preload("res://data/guests/business.tres"), preload("res://data/guests/leisure.tres")]

static func guest(id: StringName) -> GuestArchetype:
	for definition in GUESTS:
		if definition.id == id:
			return definition
	return null

static func room(id: StringName) -> RoomDefinition:
	for definition in ROOMS:
		if definition.id == id:
			return definition
	return null
