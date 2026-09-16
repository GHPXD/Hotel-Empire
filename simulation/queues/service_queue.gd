class_name ServiceQueue
extends RefCounted
## Stable actor IDs, bounded FIFO, no duplicate reservations.

var capacity: int
var members: Array[int] = []

func _init(limit: int = 12) -> void:
	capacity = limit

func join(actor_id: int) -> bool:
	if members.has(actor_id):
		return true
	if members.size() >= capacity:
		return false
	members.append(actor_id)
	return true

func leave(actor_id: int) -> void:
	members.erase(actor_id)

func take() -> int:
	return -1 if members.is_empty() else members.pop_front()
