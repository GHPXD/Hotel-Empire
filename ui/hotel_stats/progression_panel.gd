class_name ProgressionPanel
extends Window

var details: RichTextLabel

func _ready() -> void:
	title = "Objetivos do hotel"
	size = Vector2i(600, 470)
	min_size = Vector2i(450, 300)
	wrap_controls = true
	hide()
	close_requested.connect(hide)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.custom_minimum_size = Vector2(400, 220)
	details.focus_mode = Control.FOCUS_ALL
	column.add_child(details)
	var close := Button.new()
	close.text = "Fechar"
	close.custom_minimum_size.y = 42
	close.pressed.connect(hide)
	column.add_child(close)

func open_for(session: HotelSession) -> void:
	refresh(session)
	popup_centered()
	details.grab_focus()

func refresh(session: HotelSession) -> void:
	var lines: String = "[b]%s[/b]\nConstrução básica e N2 disponíveis desde o início.\nDesbloqueios são permanentes; melhorias ainda custam dinheiro.\n" % session.progression.summary()
	if session.progression.legacy_access:
		lines += "Partida anterior ao M4: acesso a N3 preservado.\n"
	var metrics := session.progression_metrics()
	for objective in HotelProgression.OBJECTIVES:
		var done: bool = session.progression.completed.has(objective.id)
		var waiting: bool = not objective.prerequisite.is_empty() and not session.progression.completed.has(objective.prerequisite)
		var status: String = "Concluído" if done else ("Aguarda objetivo anterior" if waiting else "Em andamento")
		lines += "\n[b]%s • %s[/b]\n%s\n" % [objective.display_name, status, objective.description]
		for metric: String in objective.requirements:
			var format: String = "%s: %.1f / %.1f\n" if metric == "reputation" else "%s: %.0f / %.0f\n"
			lines += format % [HotelProgression.METRIC_LABELS[metric], metrics[metric], objective.requirements[metric]]
		lines += objective.reward_text + "\n"
		for definition in HotelCatalog.ROOMS:
			if definition.required_objective == objective.id:
				lines += "Libera construção: %s • $ %d\n" % [definition.display_name, definition.build_cost]
	if details.text != lines:
		details.text = lines

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		set_input_as_handled()
