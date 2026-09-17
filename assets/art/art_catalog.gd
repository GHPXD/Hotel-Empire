class_name HotelArt
extends RefCounted
## Shared raster textures. Visual state never consumes simulation RNG.

const ROOMS: Dictionary = {
	&"reception": preload("res://assets/art/rooms/reception.png"),
	&"bedroom": preload("res://assets/art/rooms/bedroom.png"),
	&"restaurant": preload("res://assets/art/rooms/restaurant.png"),
	&"cafe": preload("res://assets/art/rooms/cafe.png"),
	&"lounge": preload("res://assets/art/rooms/lounge.png"),
	&"elevator": preload("res://assets/art/environment/elevator.png"),
}
const CITY: Texture2D = preload("res://assets/art/environment/city.png")
const GROUND: Texture2D = preload("res://assets/art/environment/ground.png")
const CORRIDOR: Texture2D = preload("res://assets/art/environment/corridor.png")
const CABIN: Texture2D = preload("res://assets/art/environment/cabin.png")

static func room(id: StringName) -> Texture2D:
	return ROOMS.get(id)

const CHARACTERS: Dictionary = {
	&"balanced": preload("res://assets/art/characters/balanced.png"),
	&"business": preload("res://assets/art/characters/business.png"),
	&"cleaner": preload("res://assets/art/characters/cleaner.png"),
	&"leisure": preload("res://assets/art/characters/leisure.png"),
	&"receptionist": preload("res://assets/art/characters/receptionist.png"),
}
const REGIONS: Dictionary = {"balanced": [[50, 67, 425, 746], [531, 66, 226, 747], [919, 72, 440, 741], [1414, 66, 247, 751]], "business": [[49, 42, 444, 780], [574, 41, 207, 783], [907, 42, 468, 783], [1403, 43, 333, 781]], "cleaner": [[33, 49, 409, 770], [520, 49, 293, 774], [912, 49, 429, 772], [1411, 49, 319, 773]], "leisure": [[33, 45, 430, 772], [505, 45, 355, 769], [904, 45, 447, 771], [1396, 45, 320, 771]], "receptionist": [[52, 43, 438, 771], [556, 45, 217, 767], [922, 47, 431, 767], [1408, 45, 278, 771]]}

static func character_id(actor: ActorState) -> StringName:
	return actor.archetype_id if actor.role == &"guest" else actor.role

static func character(actor: ActorState) -> Texture2D:
	return CHARACTERS[character_id(actor)]

static func character_region(actor: ActorState, tick: int) -> Rect2:
	var index: int = (tick + actor.id * 2) % 4 if actor.state == &"walking" else 1
	var box: Array = REGIONS[character_id(actor)][index]
	return Rect2(box[0], box[1], box[2], box[3])

static func character_scale(actor: ActorState) -> float:
	var height: float = 0.0
	for box: Array in REGIONS[character_id(actor)]:
		height = maxf(height, box[3])
	return 46.0 / height
