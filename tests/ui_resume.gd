extends SceneTree
## Separate OS process proves that continuation does not depend on in-memory objects.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game: Node = load("res://core/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	game.save_path = "user://ui-smoke.json"
	game._load()
	if game.hotel.rooms.size() != 4 or game.session.speed != 0:
		push_error("Separate process did not restore saved hotel")
		quit(1)
		return
	var previous_ticks: int = game.session.tick_count
	game.session.speed = 3
	for frame in 60:
		await process_frame
	var passed: bool = game.session.tick_count > previous_ticks
	print(JSON.stringify({"suite": "ui_resume", "passed": passed, "ticks_advanced": game.session.tick_count - previous_ticks}))
	game.queue_free()
	await process_frame
	quit(0 if passed else 1)
