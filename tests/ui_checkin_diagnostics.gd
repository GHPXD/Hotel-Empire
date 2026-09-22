extends "res://tests/ui_new_game.gd"

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	var session := HotelSession.new(91)
	var reception := session.hotel.build(HotelCatalog.room(&"reception"), 0, 0)
	var bedroom := session.hotel.build(HotelCatalog.room(&"bedroom"), 3, 0)
	bedroom.dirty = true
	session.hire(HotelSession.EMPLOYEES[0])
	session.spawn_guest()
	for tick in 250:
		session.tick(session.rules.tick)
		if CheckinDiagnostics.reason(session, reception) == "cleaning":
			break
	session.speed = 0
	game._replace_session(session)
	game._inspect_room(reception.id)
	check(game.hud.inspector.text.contains("Aguardando quarto limpo"), "inspector explains blockage")
	game._show_operations()
	var panel: OperationsPanel = game.operations_panel
	for index in panel.rows.size():
		if panel.rows[index].id == reception.id:
			panel.room_list.select(index)
	panel.refresh(session)
	check(panel.selected_details.text.contains("Aguardando quarto limpo"), "operations explains same blockage")
	var was_large: bool = game.large_text
	if not was_large:
		game._toggle_text_size()
	for frame in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	panel.get_texture().get_image().save_png("res://.runtime/checkin-diagnosis.png")
	var before := SessionSnapshot.capture(session)
	panel.refresh(session)
	compare(before, SessionSnapshot.capture(session), "diagnostic UI read-only")
	bedroom.dirty = false
	game._refresh()
	check(panel.selected_details.text.contains("Há um quarto disponível"), "selected cause updates when room ready")
	check(game.hud.inspector.text.contains("Há um quarto disponível"), "inspector updates without reselecting")
	if not was_large:
		game._toggle_text_size()
	game.queue_free()
	await process_frame
	print(JSON.stringify({"suite": "ui_checkin_diagnostics", "failures": failures}))
	quit(1 if failures else 0)
