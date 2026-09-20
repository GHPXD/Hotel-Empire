extends "res://tests/ui_management.gd"

func run() -> void:
	var session := SimulationRunner.make_hotel(765, "tower", 1000000)
	var view := HotelView.new()
	root.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.hotel = session.hotel
	view.session = session
	view.selected = session.hotel.rooms[0].id
	for index in 120:
		var actor := session.spawn_guest()
		actor.x = float(index % 20) * 0.8
		actor.floor_index = index % 20
		actor.state = &"walking" if index % 2 else &"checkin"
		actor.target_x = 0
	for room: RoomState in session.hotel.rooms:
		if room.definition().category == &"lodging":
			room.dirty = true
	var before := SessionSnapshot.capture(session)
	for zoom: float in [0.35, 1.0, 1.8]:
		for offset: Vector2 in [Vector2.ZERO, Vector2(431, 817), Vector2(-516, 1579)]:
			view.zoom_factor = zoom
			view.pan = offset
			view.cull_offscreen = false
			view.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			var reference: PackedByteArray = root.get_texture().get_image().get_data()
			view.cull_offscreen = true
			view.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			check(reference == root.get_texture().get_image().get_data(), "pixel equivalence zoom %s pan %s" % [zoom, offset])
	check(preload("res://tests/snapshot_comparison.gd").difference(before, SessionSnapshot.capture(session), "culling").is_empty(), "culling does not mutate gameplay")
	print(JSON.stringify({"suite": "ui_culling", "failures": failures, "camera_cases": 9}))
	view.queue_free()
	await process_frame
	quit(1 if failures else 0)
