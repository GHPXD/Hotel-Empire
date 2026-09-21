extends SceneTree
## Windowed profiling, separate controlled rendering from sustained simulation load.
## Synthetic render placement is never saved or fed back into gameplay.

func _initialize() -> void:
	call_deferred("run")

func summary(samples: Array[float]) -> Dictionary:
	samples.sort()
	var total: float = 0
	for value in samples:
		total += value
	return {"mean_ms": total / samples.size(), "p95_ms": samples[int((samples.size() - 1) * 0.95)], "max_ms": samples.back()}

func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var label: String = "profile"
	var render_only: bool = OS.get_cmdline_user_args().has("--render-only")
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--label="):
			label = argument.trim_prefix("--label=").validate_filename()
	var report: Dictionary = {"engine": Engine.get_version_info().string, "os": OS.get_name(), "cpu": OS.get_processor_name(), "gpu": RenderingServer.get_video_adapter_name(), "window": str(root.size), "vsync": DisplayServer.window_get_vsync_mode(), "render": [], "simulation": []}
	var view := HotelView.new()
	root.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var render_sizes: Array[int] = []
	if not OS.get_cmdline_user_args().has("--simulation-only"):
		render_sizes.assign([100, 250, 500, 1000])
	for population in render_sizes:
		var session := SimulationRunner.make_hotel(123, "tower", 1000000)
		session.speed = 0
		for index in population:
			var actor := session.spawn_guest()
			actor.x = 0.5 + float(index % 30) * 0.48
			actor.floor_index = index % session.hotel.floors
			actor.state = &"walking"
			actor.target_x = 15
		view.hotel = session.hotel
		view.session = session
		for placement in ["distributed", "all_visible"]:
			if placement == "all_visible":
				for actor: ActorState in session.actors.values():
					actor.floor_index = 0
			var frames: Array[float] = []
			var calls: Array[float] = []
			for frame in 150:
				session.tick_count = frame
				view.queue_redraw()
				var started: int = Time.get_ticks_usec()
				await process_frame
				if frame >= 30:
					frames.append((Time.get_ticks_usec() - started) / 1000.0)
					calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			var row: Dictionary = {"guests": population, "actors": session.actors.size(), "placement": placement, "frame": summary(frames), "draw_calls_mean": summary(calls).mean_ms, "memory_bytes": OS.get_static_memory_usage(), "video_memory_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)}
			report.render.append(row)
			print(JSON.stringify(row))
	view.queue_free()
	await process_frame
	var simulation_sizes: Array[int] = []
	if not render_only:
		simulation_sizes.assign([100, 250, 500, 1000])
	for population in simulation_sizes:
		var session := SimulationRunner.make_hotel(123, "tower", 1000000)
		session.opened = false
		var ticks: Array[float] = []
		var error: String = ""
		for index in 600:
			for missing in maxi(0, population - session.guest_count()):
				session.spawn_guest()
			var started: int = Time.get_ticks_usec()
			session.tick(session.rules.tick)
			if index >= 100:
				ticks.append((Time.get_ticks_usec() - started) / 1000.0)
			if index % 50 == 0:
				error = SimulationRunner.invariant_error(session, 1000000)
				if not error.is_empty():
					break
				await process_frame
		var row: Dictionary = {"target_guests_before_tick": population, "ending_guests": session.guest_count(), "mode": "arrival_overload_refill_60_sim_seconds", "tick": summary(ticks) if not ticks.is_empty() else {}, "paths": session.transport.path_requests, "departures": session.guests.completed, "memory_bytes": OS.get_static_memory_usage(), "error": error}
		report.simulation.append(row)
		print(JSON.stringify(row))
	var file := FileAccess.open("res://.runtime/m8-%s.json" % label, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	for row: Dictionary in report.simulation:
		if not row.error.is_empty():
			quit(1)
			return
	quit(0)
