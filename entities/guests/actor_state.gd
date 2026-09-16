class_name ActorState
extends RefCounted
## One lightweight simulated actor; visual nodes are not required.

var id: int
var role: StringName = &"guest"
var display_name: String
var state: StringName = &"arriving"
var x: float = -0.5
var floor_index: int = 0
var target_x: float = 0.0
var target_floor: int = 0
var target_room: int = -1
var destination_state: StringName = &"idle"
var elevator_id: int = -1
var timer: float = 0.0
var age: float = 0.0
var waiting: float = 0.0
var happiness: float = 85.0
var money: int = 320
var bedroom: int = -1
var checked_in: bool = false
var needs: Dictionary = {"hunger": 30.0, "energy": 25.0, "entertainment": 10.0, "comfort": 10.0}
var utility_scores: Dictionary = {}
var meals: int = 0
var sleeps: int = 0
var speed: float = 1.9
var skill: float = 1.0
var assignment: int = -1
var workload: float = 0.0

func travel_to(column: float, level: int, arrival: StringName) -> void:
	target_x = column
	target_floor = level
	destination_state = arrival
	state = &"walking"
	waiting = 0.0

func in_transit() -> bool:
	return state in [&"walking", &"lift_queue", &"riding"]
