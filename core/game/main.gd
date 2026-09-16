extends Node

var session := HotelSession.new()
var economy: HotelEconomy = session.economy
var hotel: HotelModel = session.hotel
var view: HotelView
var hud: HotelHUD
var selection: int = -1
var selected_actor: int = -1
var accumulator: float = 0.0
var ui_timer: float = 0.0
var save_path: String = SaveStore.DEFAULT_PATH
var new_dialog: ConfirmationDialog
var finances_dialog: FinancePanel
var staff_panel: StaffPanel
var progression_panel: ProgressionPanel
var operations_panel: OperationsPanel
var large_text: bool = false

func _ready() -> void:
	if OS.get_cmdline_user_args().has("--simulate"):
		call_deferred("_run_headless")
		return
	_register_input()
	hud = HotelHUD.new()
	add_child(hud)
	view = HotelView.new()
	view.hotel = hotel
	view.session = session
	hud.world_slot.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.cell_clicked.connect(_on_cell_clicked)
	view.cancelled.connect(_cancel)
	view.actor_clicked.connect(_select_actor)
	hud.build_requested.connect(_on_build_requested)
	hud.floor_requested.connect(_add_floor)
	hud.cancel_requested.connect(_cancel)
	hud.demolish_requested.connect(_demolish)
	hud.hire_requested.connect(_hire)
	hud.speed_requested.connect(func(value: int) -> void: session.speed = value)
	hud.open_requested.connect(func() -> void: session.opened = not session.opened)
	hud.save_requested.connect(_save)
	hud.load_requested.connect(_load)
	hud.new_requested.connect(_confirm_new)
	hud.debug_requested.connect(_toggle_debug)
	hud.finances_requested.connect(_show_finances)
	hud.staff_requested.connect(_show_staff)
	hud.upgrade_requested.connect(_upgrade_selected)
	hud.objectives_requested.connect(_show_objectives)
	hud.operations_requested.connect(_show_operations)
	hud.text_size_requested.connect(_toggle_text_size)
	operations_panel = OperationsPanel.new()
	operations_panel.theme = hud.theme
	operations_panel.filters_changed.connect(_refresh)
	operations_panel.room_requested.connect(_inspect_room)
	add_child(operations_panel)
	progression_panel = ProgressionPanel.new()
	progression_panel.theme = hud.theme
	add_child(progression_panel)
	staff_panel = StaffPanel.new()
	staff_panel.theme = hud.theme
	staff_panel.assignment_changed.connect(_refresh)
	add_child(staff_panel)
	new_dialog = ConfirmationDialog.new()
	new_dialog.theme = hud.theme
	new_dialog.title = "Novo hotel"
	new_dialog.dialog_text = "Começar do zero? Progresso não salvo será perdido.\nSeu arquivo salvo será preservado."
	new_dialog.confirmed.connect(func() -> void: _replace_session(HotelSession.new()))
	add_child(new_dialog)
	finances_dialog = FinancePanel.new()
	finances_dialog.theme = hud.theme
	finances_dialog.title = "Finanças do hotel"
	add_child(finances_dialog)
	_bind_popup(operations_panel, hud.operations_button)
	_bind_popup(progression_panel, hud.objectives_button)
	_bind_popup(staff_panel, hud.session_buttons["Equipe"])
	_bind_popup(finances_dialog, hud.session_buttons["Finanças"])
	_bind_popup(new_dialog, hud.session_buttons["Novo hotel"])
	large_text = UIPreferences.load_large_text()
	hud.set_large_text(large_text)
	hotel.changed.connect(_refresh)
	_refresh()
	hud.open_button.grab_focus()

func _process(delta: float) -> void:
	if hud == null:
		return
	accumulator += minf(delta, 0.25) * session.speed
	var previous_objectives: int = session.progression.completed.size()
	while accumulator >= session.rules.tick:
		session.tick(session.rules.tick)
		accumulator -= session.rules.tick
	if session.progression.completed.size() > previous_objectives:
		var latest: ObjectiveDefinition = HotelProgression.OBJECTIVES[session.progression.completed.size() - 1]
		hud.message.text = "Objetivo concluído: %s. %s" % [latest.display_name, latest.reward_text]
		for definition in HotelCatalog.ROOMS:
			if definition.required_objective == latest.id:
				hud.message.text += " Libera %s." % definition.display_name
	ui_timer += delta
	view.queue_redraw()
	if ui_timer >= 0.2:
		ui_timer = 0
		_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cancel()
	elif event.is_action_pressed("toggle_debug"):
		_toggle_debug()
	elif event.is_action_pressed("save_hotel"):
		_save()
	elif event.is_action_pressed("pause_hotel"):
		session.speed = 1 if session.speed == 0 else 0
	elif event.is_action_pressed("show_operations"):
		_show_operations()
	elif event.is_action_pressed("large_text"):
		_toggle_text_size()
	elif event.is_action_pressed("search_build"):
		hud.build_search.grab_focus()

func _on_build_requested(definition: RoomDefinition) -> void:
	view.blueprint = definition
	hud.message.text = "Construir %s • $ %d • clique numa posição livre." % [definition.display_name, definition.build_cost]
	view.queue_redraw()

func _on_cell_clicked(column: int, floor_index: int) -> void:
	selected_actor = -1
	if view.blueprint != null:
		var error := hotel.build_error(view.blueprint, column, floor_index)
		if not error.is_empty():
			hud.message.text = error
			return
		var room := hotel.build(view.blueprint, column, floor_index)
		selection = room.id
		hud.message.text = "%s construído. Continue construindo ou pressione Esc." % room.definition().display_name
	else:
		var room := hotel.room_at(column, floor_index)
		selection = -1 if room == null else room.id
	_refresh()

func _add_floor() -> void:
	var error := hotel.add_floor()
	hud.message.text = "Novo andar construído; elevadores existentes atendem automaticamente." if error.is_empty() else error

func _demolish() -> void:
	var error := session.demolish(selection)
	hud.message.text = "Sala demolida. Não há reembolso." if error.is_empty() else error
	if error.is_empty():
		selection = -1
	_refresh()

func _cancel() -> void:
	view.blueprint = null
	hud.message.text = "Modo de seleção. Clique numa sala para inspecionar."
	view.queue_redraw()

func _refresh() -> void:
	view.selected = selection
	view.queue_redraw()
	hud.refresh(hotel, hotel.by_id(selection))
	hud.refresh_simulation(session, selected_actor)
	hud.refresh_unlock(session, hotel.by_id(selection))
	if progression_panel.visible:
		progression_panel.refresh(session)
	if operations_panel.visible:
		operations_panel.refresh(session)
	var lift := session.transport.lift_by_id(selection)
	if lift != null:
		hud.inspector.text = "ELEVADOR #%d • N%d\n\nPassageiros: %d / %d\nFila: %d\nEspera média: %.1fs\nMaior espera: %.1fs\nUtilização: %.0f%%\nTransportados: %d\nDestino: andar %d" % [lift.room_id, hotel.by_id(selection).level, lift.passengers.size(), lift.capacity, lift.queue.members.size(), lift.average_wait(), lift.wait_max, 100 * lift.busy_seconds / maxf(session.time, 0.1), lift.delivered, lift.target_floor]

func _hire(definition: EmployeeDefinition) -> void:
	var error := session.hire(definition)
	hud.message.text = "%s contratado(a). Atribuição automática; salário $ %d/dia." % [definition.display_name, definition.salary] if error.is_empty() else error
	_refresh()

func _select_actor(id: int) -> void:
	selected_actor = id
	selection = -1
	_refresh()

func _replace_session(value: HotelSession) -> void:
	operations_panel.hide()
	operations_panel.reset_filters()
	hud.reset_catalog()
	progression_panel.hide()
	staff_panel.hide()
	staff_panel.session = null
	if hotel.changed.is_connected(_refresh):
		hotel.changed.disconnect(_refresh)
	session = value
	economy = value.economy
	hotel = value.hotel
	view.hotel = hotel
	view.session = session
	view.blueprint = null
	view.pan = Vector2.ZERO
	view.zoom_factor = 1
	selection = -1
	selected_actor = -1
	accumulator = 0
	hotel.changed.connect(_refresh)
	_refresh()

func _save() -> void:
	var error := SaveStore.save_session(session, save_path)
	hud.message.text = "Hotel salvo. Você pode fechar e continuar depois." if error.is_empty() else error

func _load() -> void:
	var result := SaveStore.load_session(save_path)
	if not result.error.is_empty():
		hud.message.text = result.error
		return
	_replace_session(result.session)
	hud.message.text = "Hotel carregado: quartos, hóspedes, filas e finanças restaurados."

func _confirm_new() -> void:
	new_dialog.popup_centered(Vector2i(450, 170))

func _toggle_debug() -> void:
	hud.debug_label.visible = not hud.debug_label.visible
	_refresh()

func _show_finances() -> void:
	var lines: String = "Caixa: $ %d\nReceita: $ %d\nDespesas operacionais: $ %d\nLucro operacional: $ %d\nInvestimento: $ %d\n\nÚLTIMAS TRANSAÇÕES\n" % [economy.cash, economy.revenue, economy.expenses, economy.profit(), economy.capital_spent]
	var costs := session.recurring_costs()
	lines = "CUSTO FIXO ATUAL / DIA\nManutenção: $ %d • Salários: $ %d • Total: $ %d\n\n" % [costs.maintenance, costs.salaries, costs.total] + lines
	for index in range(maxi(0, economy.ledger.size() - 10), economy.ledger.size()):
		var item: Dictionary = economy.ledger[index]
		lines += "%+d  %s\n" % [item.amount, item.reason]
	finances_dialog.dialog_text = lines
	finances_dialog.popup_centered(Vector2i(600, 520))
	finances_dialog.details.grab_focus()

func _show_staff() -> void:
	staff_panel.open_for(session)

func _show_objectives() -> void:
	progression_panel.open_for(session)

func _show_operations() -> void:
	operations_panel.open_for(session)

func _inspect_room(id: int) -> void:
	var room := hotel.by_id(id)
	if room == null:
		hud.message.text = "Esta sala não existe mais."
		return
	view.blueprint = null
	selection = id
	selected_actor = -1
	view.pan += view.size / 2.0 - view.room_rect(room.column, room.floor_index, room.definition().width).get_center()
	_refresh()
	hud.sidebar_scroll.ensure_control_visible(hud.inspector)

func _toggle_text_size() -> void:
	large_text = not large_text
	hud.set_large_text(large_text)
	var error := UIPreferences.save_large_text(large_text)
	hud.message.text = "Texto ampliado." if large_text else "Texto padrão."
	if error != OK:
		hud.message.text += " Não foi possível salvar a preferência."

func _bind_popup(window: Window, opener: Control) -> void:
	window.transient = true
	window.exclusive = true
	window.visibility_changed.connect(_popup_visibility.bind(window, opener))

func _popup_visibility(window: Window, opener: Control) -> void:
	if not window.visible:
		opener.grab_focus()

func _upgrade_selected() -> void:
	var error := session.upgrade_room(selection)
	hud.message.text = "Melhoria aplicada. Serviços em curso mantêm o preço combinado." if error.is_empty() else error
	_refresh()

func _register_input() -> void:
	for binding in [{"name": "toggle_debug", "key": KEY_F3}, {"name": "save_hotel", "key": KEY_S, "ctrl": true}, {"name": "pause_hotel", "key": KEY_SPACE}, {"name": "show_operations", "key": KEY_F2}, {"name": "large_text", "key": KEY_F4}, {"name": "search_build", "key": KEY_F, "ctrl": true}]:
		if InputMap.has_action(binding.name):
			continue
		InputMap.add_action(binding.name)
		var event := InputEventKey.new()
		event.physical_keycode = binding.key
		event.ctrl_pressed = binding.get("ctrl", false)
		InputMap.action_add_event(binding.name, event)

func _run_headless() -> void:
	var options := SimulationRunner.parse(OS.get_cmdline_user_args())
	if options.has("error"):
		print(JSON.stringify(options))
		get_tree().quit(2)
		return
	var result := SimulationRunner.run(options)
	var encoded := JSON.stringify(result, "\t")
	print(encoded)
	if not options.output.is_empty():
		var file := FileAccess.open(options.output, FileAccess.WRITE)
		if file == null:
			push_error("Could not write simulation report: " + options.output)
			get_tree().quit(2)
			return
		file.store_string(encoded)
		file.close()
	get_tree().quit(1 if result.has("error") or not result.get("failures", []).is_empty() else 0)
