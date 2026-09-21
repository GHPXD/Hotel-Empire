extends "res://tests/ui_new_game.gd"

class ExitProbe extends "res://core/game/main.gd":
	var did_quit: bool = false
	func _quit_game() -> void:
		did_quit = true

func run() -> void:
	var game := ExitProbe.new()
	root.add_child(game)
	current_scene = game
	game.save_path = "user://exit-dialog-test.json"
	game.session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	game.session.speed = 3
	await process_frame
	game.hud.open_button.grab_focus()
	root.close_requested.emit()
	check(game.exit_dialog.visible and not game.did_quit, "window close asks before losing hotel")
	var before := SessionSnapshot.capture(game.session)
	game._process(1.0)
	compare(before, SessionSnapshot.capture(game.session), "modal freezes simulation without changing speed")
	check(game.exit_dialog.get_cancel_button().has_focus(), "safe action initially focused")
	await dialog_key(game.exit_dialog, KEY_ESCAPE)
	check(not game.exit_dialog.visible and not game.did_quit, "escape cancels close")
	check(game.hud.open_button.has_focus(), "cancel restores focus")
	check(game.session.speed == 3, "cancel preserves chosen speed")
	game.session.speed = 0
	game._show_finances()
	check(game.finances_dialog.visible, "management popup opened before close")
	game._request_exit()
	check(not game.finances_dialog.visible and game.exit_dialog.visible, "exit replaces other modal without overlapping exclusivity")
	game.exit_dialog.get_ok_button().grab_focus()
	await dialog_key(game.exit_dialog, KEY_ENTER)
	check(game.did_quit, "save and exit requests quit")
	var loaded := SaveStore.load_session(game.save_path)
	check(loaded.error.is_empty(), "exit writes valid save")
	if loaded.error.is_empty():
		compare(SessionSnapshot.capture(game.session), SessionSnapshot.capture(loaded.session), "exit save includes current hotel")
	var saved_bytes := FileAccess.get_file_as_bytes(game.save_path)
	game.did_quit = false
	game.exit_dialog.hide()
	game.save_path = "user://directory-that-does-not-exist/exit.json"
	game._request_exit()
	game.exit_dialog.get_ok_button().grab_focus()
	await dialog_key(game.exit_dialog, KEY_ENTER)
	check(not game.did_quit and game.exit_dialog.visible, "write failure keeps hotel open")
	check(game.exit_dialog.dialog_text.contains("Não foi possível"), "write error visible in modal")
	for frame in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	game.exit_dialog.get_texture().get_image().save_png("res://.runtime/exit-save-error.png")
	game.save_path = "user://exit-dialog-test.json"
	for child: Node in game.exit_dialog.find_children("*", "Button", true, false):
		if child.text == "Sair sem salvar":
			child.grab_focus()
	await dialog_key(game.exit_dialog, KEY_ENTER)
	check(game.did_quit, "discard requests quit")
	check(saved_bytes == FileAccess.get_file_as_bytes(game.save_path), "discard preserves saved file")
	game.did_quit = false
	game.exit_dialog.hide()
	game._replace_session(HotelSession.new())
	game.hotel.add_floor()
	game._request_exit()
	check(not game.did_quit and game.exit_dialog.visible, "floor-only construction is protected")
	game.exit_dialog.hide()
	game._replace_session(HotelSession.new())
	game._request_exit()
	check(game.did_quit and not game.exit_dialog.visible, "empty hotel closes directly")
	game.queue_free()
	await process_frame
	print(JSON.stringify({"suite": "ui_exit", "failures": failures}))
	quit(1 if failures else 0)
