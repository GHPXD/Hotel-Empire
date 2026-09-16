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
	await press_button(buttons[0])
	check(game.view.blueprint != null, "build button via input")
	var cell: Vector2 = game.view.room_rect(0, 0).get_center() + game.view.global_position
	await click(cell)
	check(game.hotel.rooms.size() == 1, "construction via viewport input")
	await click(cell)
	check(game.hotel.rooms.size() == 1, "overlap rejected through UI")
	await press_button(buttons[4])
	check(game.hotel.floors == 2, "floor button via input")
	await press_button(buttons[1])
	await click(game.view.room_rect(3, 1).get_center() + game.view.global_position)
	await press_button(buttons[2])
	await click(game.view.room_rect(5, 0).get_center() + game.view.global_position)
	await press_button(buttons[3])
	await click(game.view.room_rect(12, 0).get_center() + game.view.global_position)
	check(game.hotel.rooms.size() == 4, "four room types built")
	await press_button(buttons[5])
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
	game.save_path = "user://ui-smoke.json"
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text == "Salvar":
			await click(button.get_global_rect().get_center())
	check(FileAccess.file_exists(game.save_path), "save button writes file")
	var snapshot := SessionSnapshot.capture(game.session)
	game._replace_session(HotelSession.new())
	check(game.session.actors.is_empty() and game.hotel.rooms.is_empty(), "new session clears run state")
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text == "Carregar":
			await click(button.get_global_rect().get_center())
	var restored := SessionSnapshot.capture(game.session)
	var mismatch: String = preload("res://tests/snapshot_comparison.gd").difference(snapshot, restored, "ui-load")
	check(mismatch.is_empty(), "load button restores entire paused session: " + mismatch)
	var world_center: Vector2 = game.view.global_position + game.view.size / 2
	var zoom_before: float = game.view.zoom_factor
	var wheel := InputEventMouseButton.new()
	wheel.position = world_center
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	root.push_input(wheel, true)
	await process_frame
	check(game.view.zoom_factor > zoom_before, "wheel zoom")
	var pan_before: Vector2 = game.view.pan
	var middle := InputEventMouseButton.new()
	middle.position = world_center
	middle.button_index = MOUSE_BUTTON_MIDDLE
	middle.pressed = true
	root.push_input(middle, true)
	await process_frame
	var movement := InputEventMouseMotion.new()
	movement.position = world_center + Vector2(25, 15)
	movement.relative = Vector2(25, 15)
	movement.button_mask = MOUSE_BUTTON_MASK_MIDDLE
	root.push_input(movement, true)
	await process_frame
	middle.pressed = false
	root.push_input(middle, true)
	check(game.view.pan != pan_before, "middle button pan")
	game.view.pan = Vector2.ZERO
	game.view.zoom_factor = 1
	var debug_key := InputEventKey.new()
	debug_key.physical_keycode = KEY_F3
	debug_key.pressed = true
	root.push_input(debug_key, true)
	await process_frame
	check(game.hud.debug_label.visible, "keyboard debug toggle")
	debug_key.pressed = false
	root.push_input(debug_key, true)
	game.hud.debug_label.visible = false
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

func press_button(button: Button) -> void:
	var scroll: ScrollContainer = button.get_parent().get_parent()
	scroll.ensure_control_visible(button)
	for frame in 3:
		await process_frame
	await click(button.get_global_rect().get_center())
