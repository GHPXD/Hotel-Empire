class_name HotelCatalog
extends RefCounted

const ROOMS: Array[RoomDefinition] = [
	preload("res://data/rooms/reception.tres"),
	preload("res://data/rooms/bedroom.tres"),
	preload("res://data/rooms/restaurant.tres"),
	preload("res://data/rooms/elevator.tres"),
]

static func room(id: StringName) -> RoomDefinition:
	for definition in ROOMS:
		if definition.id == id:
			return definition
	return null
