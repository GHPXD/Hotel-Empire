extends SceneTree

var failures: int = 0

func _initialize() -> void:
	var economy := HotelEconomy.new()
	check(economy.purchase(800, "reception", 0.0), "affordable purchase")
	check(economy.cash == 11200 and economy.capital_spent == 800, "capital ledger")
	check(not economy.purchase(20000, "invalid", 0.0), "reject unaffordable purchase")
	economy.transact(140, "booking", 1.0)
	economy.transact(-30, "salary", 2.0)
	check(economy.profit() == 110 and economy.cash == 11310, "operating profit")
	var queue := ServiceQueue.new(2)
	check(queue.join(1) and queue.join(1) and queue.join(2), "unique queue members")
	check(not queue.join(3), "queue capacity")
	check(queue.take() == 1 and queue.take() == 2 and queue.take() == -1, "FIFO")
	check(HotelCatalog.ROOMS.size() == 6 and HotelCatalog.room(&"bedroom").price == 140, "resource catalog")
	print(JSON.stringify({"suite": "foundation", "failures": failures}))
	quit(1 if failures else 0)

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
