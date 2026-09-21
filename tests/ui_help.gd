extends "res://tests/ui_new_game.gd"

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var previous_large: bool = game.large_text
	game.session.speed = 3
	for frame in 4:
		await process_frame
	await click(root, game.hud.help_button.get_global_rect().get_center())
	check(game.help_panel.visible, "help button opens guide")
	var before := SessionSnapshot.capture(game.session)
	game._process(2.0)
	compare(before, SessionSnapshot.capture(game.session), "guide pauses without changing session")
	check(game.help_panel.details.has_focus(), "keyboard focus on scrollable guide")
	await dialog_key(game.help_panel, KEY_END)
	check(game.help_panel.details.get_v_scroll_bar().value > 0, "End scrolls guide by keyboard")
	await dialog_key(game.help_panel, KEY_ESCAPE)
	check(not game.help_panel.visible and game.hud.help_button.has_focus(), "escape closes and restores focus")
	check(game.session.speed == 3, "guide retains speed")
	game.session.speed = 0
	await key(root, KEY_F1)
	check(game.help_panel.visible, "F1 opens guide")
	if not game.large_text:
		game._toggle_text_size()
	for frame in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	game.help_panel.get_texture().get_image().save_png("res://.runtime/help-large.png")
	game.help_panel.details.scroll_to_line(game.help_panel.details.get_line_count() - 1)
	for frame in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	game.help_panel.get_texture().get_image().save_png("res://.runtime/help-bottom.png")
	check(game.help_panel.details.get_v_scroll_bar().value > 0, "long guide remains scrollable")
	if game.large_text != previous_large:
		game._toggle_text_size()
	game._replace_session(HotelSession.new())
	check(not game.help_panel.visible, "replacing hotel closes guide")
	game.queue_free()
	await process_frame
	print(JSON.stringify({"suite": "ui_help", "failures": failures}))
	quit(1 if failures else 0)
