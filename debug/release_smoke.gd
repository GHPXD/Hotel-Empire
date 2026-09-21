extends RefCounted
## Explicit --release-smoke diagnostic; uses only dedicated test save/report names.

var failures: int = 0

func run(game: Node) -> void:
	var tree: SceneTree = game.get_tree()
	var root: Window = tree.root
	check(not OS.has_feature("editor"), "running export template")
	check(not ResourceLoader.exists("res://tests/ui_art.gd"), "tests excluded from package")
	check(not FileAccess.file_exists("res://docs/PRODUCT_VISION.md"), "documentation excluded")
	var session := HotelSession.new(123)
	session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	session.hotel.build(HotelCatalog.room(&"restaurant"), 3, 0)
	session.hotel.build(HotelCatalog.room(&"elevator"), 6, 0)
	for level: int in [1, 2]:
		session.hotel.add_floor()
		for column: int in [0, 2, 4, 8]:
			session.hotel.build(HotelCatalog.room(&"bedroom"), column, level)
	for definition: EmployeeDefinition in HotelSession.EMPLOYEES:
		check(session.hire(definition).is_empty(), "hire from exported data")
	check(session.hotel.rooms.size() == 11, "build from exported data")
	session.opened = true
	for tick in 6000:
		session.tick(session.rules.tick)
	check(session.guests.bookings >= 10 and session.guests.meals_served >= 5 and session.employees.cleaned >= 5, "productive packaged game")
	check(session.economy.cash > 0, "solvent packaged game")
	var path := "user://release-smoke-save.json"
	check(SaveStore.save_session(session, path).is_empty(), "save from executable")
	var restored := SaveStore.load_session(path)
	check(restored.error.is_empty(), "load from executable")
	if restored.error.is_empty():
		for tick in 120:
			session.tick(session.rules.tick)
			restored.session.tick(restored.session.rules.tick)
		check(equivalent(SessionSnapshot.capture(session), SessionSnapshot.capture(restored.session)), "continued save equivalent")
	for texture: Texture2D in HotelArt.CHARACTERS.values():
		check(texture.get_width() > 0, "character texture packaged")
	for texture: Texture2D in HotelArt.ROOMS.values():
		check(texture.get_width() > 0, "room texture packaged")
	for cue: AudioStream in HotelAudio.SOUNDS.values():
		check(cue.get_length() > 0.1, "sound packaged")
	session.speed = 0
	game._replace_session(session)
	game.save_path = path
	for frame in 4:
		await tree.process_frame
	await click(tree, game.hud.session_buttons["Salvar"].get_global_rect().get_center())
	var expected := SessionSnapshot.capture(game.session)
	game._replace_session(HotelSession.new(777))
	game.session.speed = 0
	if OS.get_cmdline_user_args().has("--smoke-large-text") and not game.large_text:
		game._toggle_text_size()
		for frame in 3:
			await tree.process_frame
	for button: Control in [game.hud.open_button, game.hud.session_buttons["Salvar"], game.hud.session_buttons["Carregar"], game.hud.operations_button]:
		check(root.get_visible_rect().encloses(button.get_global_rect()), "essential toolbar control fits viewport")
	await click(tree, game.hud.session_buttons["Carregar"].get_global_rect().get_center())
	check(equivalent(expected, SessionSnapshot.capture(game.session)), "toolbar restores packaged session")
	game.session.speed = 0
	game._show_finances()
	game.get_tree().root.close_requested.emit()
	check(game.exit_dialog.visible, "packaged close asks before exit")
	check(not game.finances_dialog.visible, "packaged exit replaces management popup")
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		event.physical_keycode = KEY_ESCAPE
		event.pressed = pressed
		event.window_id = game.exit_dialog.get_window_id()
		Input.parse_input_event(event)
		await tree.process_frame
	check(not game.exit_dialog.visible, "packaged exit cancellation resumes game")
	check(equivalent(expected, SessionSnapshot.capture(game.session)), "exit cancellation preserves packaged session")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png("user://release-smoke.png") == OK, "capture packaged game")
	var report: Dictionary = {"suite": "release_smoke", "failures": failures, "bookings": session.guests.bookings, "meals": session.guests.meals_served, "cleaned": session.employees.cleaned, "cash": session.economy.cash, "ticks": session.tick_count, "user_data": OS.get_user_data_dir(), "executable": OS.get_executable_path()}
	report["presentation"] = {"window": [root.size.x, root.size.y], "viewport": [root.get_visible_rect().size.x, root.get_visible_rect().size.y], "large_text": game.large_text, "display": DisplayServer.get_name(), "renderer": RenderingServer.get_current_rendering_method(), "adapter": RenderingServer.get_video_adapter_name(), "os": OS.get_name(), "os_version": OS.get_version()}
	var file := FileAccess.open("user://release-smoke-report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print(JSON.stringify(report))
	tree.quit(1 if failures else 0)

func click(tree: SceneTree, point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	tree.root.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.pressed = pressed
		tree.root.push_input(event, true)
		await tree.process_frame

func equivalent(a: Variant, b: Variant) -> bool:
	if (a is float or a is int) and (b is float or b is int):
		return absf(float(a) - float(b)) < 0.00000001
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key: Variant in a:
			if not b.has(key) or not equivalent(a[key], b[key]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for index in a.size():
			if not equivalent(a[index], b[index]):
				return false
		return true
	return a == b

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
