class_name ElevatorState
extends RefCounted

var room_id: int
var column: float
var capacity: int = 4
var speed_multiplier: float = 1.0
var floor_position: float = 0.0
var target_floor: int = 0
var door_timer: float = 0.0
var queue := ServiceQueue.new(2000)
var passengers: Array[int] = []
var boarded: int = 0
var delivered: int = 0
var wait_total: float = 0.0
var wait_max: float = 0.0
var busy_seconds: float = 0.0

func average_wait() -> float:
	return wait_total / maxi(1, boarded)
