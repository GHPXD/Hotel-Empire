extends SceneTree

var failures: int = 0

func _initialize() -> void:
	var wallet := HotelEconomy.new()
	var hotel := HotelModel.new(wallet)
	var reception := HotelCatalog.room(&"reception")
	var bedroom := HotelCatalog.room(&"bedroom")
	var elevator := HotelCatalog.room(&"elevator")
	check(hotel.build(reception, 0, 0) != null, "ground floor reception")
	check(hotel.build(bedroom, 2, 0) == null, "overlap rejected")
	check(hotel.build(bedroom, -1, 0) == null, "negative column rejected")
	check(hotel.build(bedroom, 15, 0) == null, "right boundary rejected")
	check(hotel.build(bedroom, 4, 1) == null, "floating room rejected")
	check(hotel.add_floor().is_empty(), "floor purchase")
	check(hotel.build(reception, 4, 1) == null, "upstairs reception rejected")
	check(hotel.build(bedroom, 5, 1) != null, "upstairs bedroom")
	check(hotel.build(elevator, 5, 0) == null, "shaft collision upstairs")
	var shaft := hotel.build(elevator, 15, 1)
	check(shaft != null and hotel.room_at(15, 0) == shaft, "shaft spans all floors")
	check(hotel.room_at(15, -1) == null and hotel.room_at(15, 5) == null, "shaft cannot be selected beyond hotel")
	check(hotel.add_floor().is_empty() and hotel.room_at(15, 2) == shaft, "shaft extends on expansion")
	var before: int = wallet.cash
	check(hotel.demolish(shaft.id).is_empty() and wallet.cash == before, "demolition no refund")
	wallet.cash = 0
	check(hotel.build(bedroom, 8, 0) == null, "insufficient cash")
	check(not hotel.add_floor().is_empty() and hotel.floors == 3, "floor requires cash")
	var occupied := hotel.rooms[0]
	occupied.occupant = 23
	check(not hotel.demolish(occupied.id).is_empty(), "busy demolition rejected")
	print(JSON.stringify({"suite": "construction", "checks": 16, "failures": failures}))
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
