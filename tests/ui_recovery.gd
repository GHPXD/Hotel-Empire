extends "res://tests/ui_new_game.gd"

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.save_path = "user://recovery-ui-test.json"
	var source := SimulationRunner.make_hotel(12, "standard", 250000)
	source.speed = 0
	check(SaveStore.save_session(source, game.save_path).is_empty(), "write old save")
	var expected := SessionSnapshot.capture(source)
	source.hotel.add_floor()
	check(SaveStore.save_session(source, game.save_path).is_empty(), "rotate valid backup")
	var backup_bytes := FileAccess.get_file_as_bytes(game.save_path + ".bak")
	write_text(game.save_path, "{broken")
	game.session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	game.session.speed = 0
	for frame in 4:
		await process_frame
	var current := SessionSnapshot.capture(game.session)
	await click(root, game.hud.session_buttons["Carregar"].get_global_rect().get_center())
	check(game.recovery_dialog.visible, "corrupt primary offers valid backup")
	check(game.recovery_dialog.get_cancel_button().has_focus(), "recovery defaults to keeping current run")
	game.session.speed = 3
	var paused := SessionSnapshot.capture(game.session)
	game._process(1.0)
	compare(paused, SessionSnapshot.capture(game.session), "recovery freezes running simulation")
	game.session.speed = 0
	compare(current, SessionSnapshot.capture(game.session), "recovery prompt preserves run")
	await dialog_key(game.recovery_dialog, KEY_ESCAPE)
	check(not game.recovery_dialog.visible and game.recovery_session == null, "cancel clears candidate")
	compare(current, SessionSnapshot.capture(game.session), "cancel keeps current session")
	await click(root, game.hud.session_buttons["Carregar"].get_global_rect().get_center())
	game.recovery_dialog.get_ok_button().grab_focus()
	await RenderingServer.frame_post_draw
	game.recovery_dialog.get_texture().get_image().save_png("res://.runtime/recovery-dialog.png")
	await dialog_key(game.recovery_dialog, KEY_ENTER)
	compare(expected, SessionSnapshot.capture(game.session), "recovery restores older snapshot")
	check(FileAccess.get_file_as_string(game.save_path) == "{broken", "recovery leaves primary untouched")
	check(FileAccess.get_file_as_bytes(game.save_path + ".bak") == backup_bytes, "recovery preserves backup bytes")
	check(DirAccess.remove_absolute(ProjectSettings.globalize_path(game.save_path)) == OK, "remove primary for missing-file scenario")
	game._load()
	check(game.recovery_dialog.visible, "missing primary also offers backup")
	await dialog_key(game.recovery_dialog, KEY_ESCAPE)
	write_text(game.save_path + ".bak", "{broken")
	game._load()
	check(not game.recovery_dialog.visible, "invalid backup never offered")
	compare(expected, SessionSnapshot.capture(game.session), "invalid files preserve open hotel")
	check(SaveStore.save_session(source, game.save_path).is_empty(), "write valid primary")
	game._load()
	check(not game.recovery_dialog.visible, "valid primary takes precedence over invalid backup")
	compare(SessionSnapshot.capture(source), SessionSnapshot.capture(game.session), "normal load unaffected")
	game.queue_free()
	await process_frame
	print(JSON.stringify({"suite": "ui_recovery", "failures": failures}))
	quit(1 if failures else 0)

func write_text(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
