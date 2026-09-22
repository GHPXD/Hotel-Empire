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

const ROOM_UPGRADES: Dictionary = {
	&"bedroom": preload("res://assets/art/rooms/bedroom-level-2.png"),
	&"reception": preload("res://assets/art/rooms/reception-level-2.png"),
}

static func room(id: StringName, level: int = 1) -> Texture2D:
	if level >= 2 and ROOM_UPGRADES.has(id):
		return ROOM_UPGRADES[id]
	return ROOMS.get(id)

const CHARACTERS: Dictionary = {
	&"cleaner-cleaning": preload("res://assets/art/characters/cleaner-cleaning.png"),
	&"receptionist-working": preload("res://assets/art/characters/receptionist-working.png"),
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
	return CHARACTERS[animation_id(actor)]

const ACTION_REGIONS: Dictionary = {
	&"cleaner-cleaning": [[111, 88, 289, 710], [506, 104, 387, 694], [974, 91, 294, 707], [1364, 109, 384, 694]],
	&"receptionist-working": [[121, 44, 271, 796], [531, 60, 297, 780], [955, 43, 275, 797], [1353, 41, 390, 799]],
}

static func animation_id(actor: ActorState) -> StringName:
	if actor.role == &"cleaner" and actor.state == &"cleaning":
		return &"cleaner-cleaning"
	if actor.role == &"receptionist" and actor.state == &"working":
		return &"receptionist-working"
	return character_id(actor)

static func character_regions(actor: ActorState) -> Array:
	var id := animation_id(actor)
	return ACTION_REGIONS[id] if ACTION_REGIONS.has(id) else REGIONS[id]

static func character_region(actor: ActorState, tick: int) -> Rect2:
	var index: int = (tick + actor.id * 2) % 4 if actor.state == &"walking" else 1
	if ACTION_REGIONS.has(animation_id(actor)):
		# Deliberate work gestures at 2.5 fps; pausing freezes the authoritative tick.
		index = (floori(tick / 4.0) + actor.id) % 4
	var box: Array = character_regions(actor)[index]
	return Rect2(box[0], box[1], box[2], box[3])

static func character_scale(actor: ActorState) -> float:
	var height: float = 0.0
	for box: Array in character_regions(actor):
		height = maxf(height, box[3])
	return 46.0 / height
