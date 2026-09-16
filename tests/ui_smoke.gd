extends SceneTree
## Run windowed: validates viewport input and captures our own rendered viewport.

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for frame in 5:
		await process_frame
	var buttons: Array[Node] = []
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text.contains("células") or button.text.begins_with("+ Andar") or button.text in ["Selecionar / cancelar", "Demolir seleção"]:
			buttons.append(button)
	await click(buttons[0].get_global_rect().get_center())
	check(game.view.blueprint != null, "build button via input")
	var cell: Vector2 = game.view.room_rect(0, 0).get_center() + game.view.global_position
	await click(cell)
	check(game.hotel.rooms.size() == 1, "construction via viewport input")
	await click(cell)
	check(game.hotel.rooms.size() == 1, "overlap rejected through UI")
	await click(buttons[4].get_global_rect().get_center())
	check(game.hotel.floors == 2, "floor button via input")
	await click(buttons[1].get_global_rect().get_center())
	await click(game.view.room_rect(3, 1).get_center() + game.view.global_position)
	await click(buttons[2].get_global_rect().get_center())
	await click(game.view.room_rect(5, 0).get_center() + game.view.global_position)
	await click(buttons[3].get_global_rect().get_center())
	await click(game.view.room_rect(12, 0).get_center() + game.view.global_position)
	check(game.hotel.rooms.size() == 4, "four room types built")
	await click(buttons[5].get_global_rect().get_center())
	check(game.view.blueprint == null, "cancel construction")
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text.begins_with("+ Recepcionista") or button.text.begins_with("+ Camareiro"):
			var scroll: ScrollContainer = button.get_parent().get_parent()
			scroll.ensure_control_visible(button)
			await process_frame
			await click(button.get_global_rect().get_center())
	check(game.session.actors.size() == 2, "hire both employees through UI")
	await click(game.hud.open_button.get_global_rect().get_center())
	check(game.session.opened, "open arrivals")
	for tick in 1200:
		game.session.tick(0.1)
	game._refresh()
	for frame in 3:
		await process_frame
	check(game.session.guests.bookings > 0 and game.session.economy.revenue > 0, "operating hotel generates revenue")
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text == "Pausa":
			await click(button.get_global_rect().get_center())
	check(game.session.speed == 0, "pause button")
	await RenderingServer.frame_post_draw
	var path: String = "res://.runtime/construction-ui.png"
	root.get_texture().get_image().save_png(path)
	print(JSON.stringify({"suite": "ui_smoke", "failures": failures, "capture": path}))
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

func click(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame
	await process_frame

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
