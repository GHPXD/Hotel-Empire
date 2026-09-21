extends "res://tests/ui_management.gd"
## Exercise the actual confirmation dialog; preserve the on-disk hotel throughout.

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var session := SimulationRunner.make_hotel(81, "standard", 250000)
	session.opened = true
	for index in 600:
		session.tick(session.rules.tick)
	session.speed = 0
	game._replace_session(session)
	game.save_path = "user://new-game-dialog-test.json"
	for frame in 4:
		await process_frame
	var before := SessionSnapshot.capture(session)
	var old_text_size: bool = game.large_text
	await click(root, game.hud.session_buttons["Salvar"].get_global_rect().get_center())
	var saved_bytes: PackedByteArray = FileAccess.get_file_as_bytes(game.save_path)
	check(not saved_bytes.is_empty(), "fixture saved through toolbar")
	var opener: Button = game.hud.session_buttons["Novo hotel"]
	await click(root, opener.get_global_rect().get_center())
	check(game.new_dialog.visible, "new hotel opens confirmation")
	await dialog_key(game.new_dialog, KEY_ESCAPE)
	check(not game.new_dialog.visible, "cancel closes dialog")
	check(opener.has_focus(), "cancel restores toolbar focus")
	compare(before, SessionSnapshot.capture(game.session), "cancel retains entire run")
	check(saved_bytes == FileAccess.get_file_as_bytes(game.save_path), "cancel preserves saved bytes")
	await click(root, opener.get_global_rect().get_center())
	game.new_dialog.get_ok_button().grab_focus()
	await dialog_key(game.new_dialog, KEY_ENTER)
	check(not game.new_dialog.visible, "confirm closes dialog")
	check(game.hotel.rooms.is_empty() and game.hotel.floors == 1 and game.session.actors.is_empty(), "confirm resets rooms actors and floors")
	check(game.session.progression.completed.is_empty() and game.session.guests.bookings == 0, "confirm resets objectives and statistics")
	check(game.session.economy.cash == HotelSession.new().economy.cash, "confirm restores starting funds")
	check(game.selection == -1 and game.selected_actor == -1 and game.view.blueprint == null, "selection and construction reset")
	check(game.large_text == old_text_size, "device text preference survives new run")
	check(saved_bytes == FileAccess.get_file_as_bytes(game.save_path), "new hotel does not overwrite save")
	await click(root, game.hud.session_buttons["Carregar"].get_global_rect().get_center())
	compare(before, SessionSnapshot.capture(game.session), "saved hotel can be recovered after confirmation")
	print(JSON.stringify({"suite": "ui_new_game", "failures": failures}))
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

func compare(left: Dictionary, right: Dictionary, label: String) -> void:
	check(preload("res://tests/snapshot_comparison.gd").difference(left, right, label).is_empty(), label)

func dialog_key(window: Window, code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		event.window_id = window.get_window_id()
		Input.parse_input_event(event)
		await process_frame
	await process_frame
