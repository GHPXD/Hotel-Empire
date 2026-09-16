class_name RoomState
extends RefCounted

var id: int
var definition_id: StringName
var column: int
var floor_index: int
var occupant: int = -1
var dirty: bool = false
var cleaning_by: int = -1
var users: Array[int] = []
var queue := ServiceQueue.new()
var income: int = 0

func definition() -> RoomDefinition:
	return HotelCatalog.room(definition_id)

func center() -> float:
	return float(column) + float(definition().width) / 2.0

func busy() -> bool:
	return occupant >= 0 or cleaning_by >= 0 or not users.is_empty() or not queue.members.is_empty()
