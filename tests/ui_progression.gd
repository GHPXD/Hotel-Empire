extends "res://tests/ui_management.gd"

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var session := SimulationRunner.make_hotel(123, "standard", 250000)
	session.speed = 0
	game._replace_session(session)
	game.save_path = "user://progression-ui.json"
	game.selection = session.hotel.rooms[0].id
	game._refresh()
	for frame in 5:
		await process_frame
	check(not game.progression_panel.visible, "objectives hidden on boot")
	var room := session.hotel.by_id(game.selection)
	var scroll: ScrollContainer = game.hud.upgrade_button.get_parent().get_parent()
	scroll.ensure_control_visible(game.hud.upgrade_button)
	for frame in 3:
		await process_frame
	await click(root, game.hud.upgrade_button.get_global_rect().get_center())
	check(room.level == 2 and game.hud.upgrade_button.disabled, "N2 purchased, N3 visibly locked")
	check(game.hud.upgrade_preview.text.contains("Primeiras estadias"), "lock explains objective")
	scroll.ensure_control_visible(game.hud.upgrade_button)
	for frame in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.runtime/m4-locked.png")
	await click(root, game.hud.objectives_button.get_global_rect().get_center())
	check(game.progression_panel.visible, "objectives open by toolbar")
	check(game.progression_panel.details.text.contains("Reservas: 0 / 3"), "current requirement visible")
	# UI fixture crosses the threshold; actual service production is tested headlessly.
	session.guests.bookings = 3
	session.tick(0.1)
	game._refresh()
	check(game.progression_panel.details.text.contains("Primeiras estadias • Concluído"), "open panel refreshes after completion")
	check(game.hud.objectives_button.text == "Objetivos 1/3", "persistent completion counter")
	await RenderingServer.frame_post_draw
	game.progression_panel.get_texture().get_image().save_png("res://.runtime/m4-objectives.png")
	game.progression_panel.details.scroll_to_line(game.progression_panel.details.get_line_count() - 1)
	await process_frame
	await RenderingServer.frame_post_draw
	game.progression_panel.get_texture().get_image().save_png("res://.runtime/m4-objectives-bottom.png")
	await key(game.progression_panel, KEY_ESCAPE)
	check(not game.progression_panel.visible, "escape closes objectives")
	scroll.ensure_control_visible(game.hud.upgrade_button)
	for frame in 3:
		await process_frame
	check(not game.hud.upgrade_button.disabled, "N3 enabled after objective")
	await click(root, game.hud.upgrade_button.get_global_rect().get_center())
	check(room.level == 3, "unlocked upgrade purchased through UI")
	await toolbar(game, "Salvar")
	game._replace_session(HotelSession.new())
	game.session.speed = 0
	check(game.session.progression.completed.is_empty(), "new session resets visible state")
	await toolbar(game, "Carregar")
	check(game.session.progression.completed.size() == 1 and game.session.hotel.rooms[0].level == 3, "UI save/load restores unlock and room")
	await click(root, game.hud.objectives_button.get_global_rect().get_center())
	check(game.progression_panel.details.text.contains("Primeiras estadias • Concluído"), "reopened panel reads restored session")
	game._replace_session(HotelSession.new())
	check(not game.progression_panel.visible and game.hud.objectives_button.text == "Objetivos 0/3", "replace hides old progress panel")
	print(JSON.stringify({"suite": "ui_progression", "failures": failures}))
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)

func toolbar(game: Node, label: String) -> void:
	for button: Node in game.hud.find_children("*", "Button", true, false):
		if button.text == label:
			await click(root, button.get_global_rect().get_center())
			return
	check(false, "missing toolbar button " + label)
