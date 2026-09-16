class_name HotelHUD
extends Control

signal build_requested(definition: RoomDefinition)
signal floor_requested
signal demolish_requested
signal cancel_requested
signal hire_requested(definition: EmployeeDefinition)
signal speed_requested(value: int)
signal open_requested
signal save_requested
signal load_requested
signal new_requested
signal debug_requested
signal finances_requested
signal staff_requested
signal upgrade_requested

var stats: Label
var message: Label
var inspector: Label
var world_slot: Control
var operations: Label
var open_button: Button
var debug_label: Label
var upgrade_button: Button
var upgrade_preview: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_theme()
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 0)
	add_child(layout)
	var header := PanelContainer.new()
	layout.add_child(header)
	var header_row := HBoxContainer.new()
	header.add_child(header_row)
	var title := Label.new()
	title.text = "  HOTEL EMPIRE  "
	title.add_theme_font_size_override("font_size", 24)
	header_row.add_child(title)
	stats = Label.new()
	stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_row.add_child(stats)
	var toolbar := HBoxContainer.new()
	layout.add_child(toolbar)
	open_button = Button.new()
	open_button.custom_minimum_size.x = 175
	open_button.text = "Abrir hotel"
	open_button.pressed.connect(func() -> void: open_requested.emit())
	toolbar.add_child(open_button)
	for speed_value in [0, 1, 2, 3]:
		_button(toolbar, "Pausa" if speed_value == 0 else "%dx" % speed_value, func() -> void: speed_requested.emit(speed_value))
	operations = Label.new()
	operations.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	operations.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toolbar.add_child(operations)
	var session_bar := HBoxContainer.new()
	layout.add_child(session_bar)
	_button(session_bar, "Novo hotel", func() -> void: new_requested.emit())
	_button(session_bar, "Salvar", func() -> void: save_requested.emit())
	_button(session_bar, "Carregar", func() -> void: load_requested.emit())
	_button(session_bar, "Finanças", func() -> void: finances_requested.emit())
	_button(session_bar, "Equipe", func() -> void: staff_requested.emit())
	_button(session_bar, "Debug • F3", func() -> void: debug_requested.emit())
	debug_label = Label.new()
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	debug_label.visible = false
	session_bar.add_child(debug_label)
	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 0)
	layout.add_child(content)
	world_slot = Control.new()
	world_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(world_slot)
	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size.x = 265
	content.add_child(sidebar)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sidebar.add_child(scroll)
	var tools := VBoxContainer.new()
	tools.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools.add_theme_constant_override("separation", 10)
	scroll.add_child(tools)
	var build_title := Label.new()
	build_title.text = "CONSTRUIR"
	tools.add_child(build_title)
	for definition in HotelCatalog.ROOMS:
		var button := Button.new()
		button.text = "%s\n$ %d   •   %d células" % [definition.display_name, definition.build_cost, definition.width]
		button.tooltip_text = "Manutenção: $ %d/dia • Capacidade: %d\nDisponível desde o início" % [definition.maintenance, definition.capacity]
		button.custom_minimum_size.y = 58
		button.pressed.connect(func() -> void: build_requested.emit(definition))
		tools.add_child(button)
	_button(tools, "+ Andar   •   $ 750", func() -> void: floor_requested.emit())
	_button(tools, "Selecionar / cancelar", func() -> void: cancel_requested.emit())
	_button(tools, "Demolir seleção", func() -> void: demolish_requested.emit())
	var staff_title := Label.new()
	staff_title.text = "EQUIPE"
	tools.add_child(staff_title)
	for definition in HotelSession.EMPLOYEES:
		_button(tools, "+ %s • $ %d" % [definition.display_name, definition.hire_cost], func() -> void: hire_requested.emit(definition))
	inspector = Label.new()
	inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector.text = "Construa uma recepção no térreo para começar."
	inspector.custom_minimum_size.x = 235
	tools.add_child(inspector)
	upgrade_preview = Label.new()
	upgrade_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tools.add_child(upgrade_preview)
	upgrade_button = Button.new()
	upgrade_button.custom_minimum_size.y = 44
	upgrade_button.pressed.connect(func() -> void: upgrade_requested.emit())
	tools.add_child(upgrade_button)
	var footer := PanelContainer.new()
	layout.add_child(footer)
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.text = "Bem-vindo. Escolha uma sala e clique no terreno."
	footer.add_child(message)

func refresh(hotel: HotelModel, selected: RoomState) -> void:
	upgrade_button.visible = selected != null
	upgrade_preview.visible = selected != null
	stats.text = "$ %s    |    %d andar(es)    |    Investido: $ %d" % [hotel.economy.cash, hotel.floors, hotel.economy.capital_spent]
	if selected != null:
		var definition := selected.definition()
		inspector.text = "%s  #%d • N%d\n\nCapacidade: %d\nUsuários: %d\nFila: %d\nReceita: $ %d\nTarifa: $ %d\nAtendimento: %.1fs\nManutenção: $ %d/dia\n\nDemolição sem reembolso." % [definition.display_name, selected.id, selected.level, selected.capacity(), selected.users.size(), selected.queue.members.size(), selected.income, selected.price(), selected.duration(), selected.maintenance()]
		var next := selected.next_upgrade()
		upgrade_button.disabled = next == null or hotel.economy.cash < next.cost
		upgrade_button.text = "Nível máximo" if next == null else "Melhorar para N%d • $ %d" % [selected.level + 1, next.cost]
		upgrade_preview.text = "" if next == null else "PRÓXIMO NÍVEL\nCapacidade: %d → %d\nTarifa: $ %d → $ %d\nManutenção: $ %d → $ %d/dia" % [selected.capacity(), definition.capacity + next.capacity_bonus, selected.price(), definition.price + next.price_bonus, selected.maintenance(), definition.maintenance + next.maintenance_bonus]
		if next != null and definition.category == &"transport":
			upgrade_preview.text += "\nVelocidade: %.2fx → %.2fx" % [selected.speed_multiplier(), next.speed_multiplier]
		elif next != null:
			upgrade_preview.text += "\nAtendimento: %.1fs → %.1fs\nBônus satisfação: +%.0f → +%.0f" % [selected.duration(), definition.service_duration * next.duration_multiplier, selected.satisfaction_bonus(), next.satisfaction_bonus]
	else:
		inspector.text = "SEU PRIMEIRO HOTEL\n\n1. Recepção no térreo\n2. Quartos para hospedar\n3. Bistrô para refeições\n4. Elevador para expandir\n\nPoços ocupam a mesma coluna em todos os andares."

func _button(parent: Control, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.pressed.connect(action)
	parent.add_child(button)

func refresh_simulation(session: HotelSession, actor_id: int) -> void:
	stats.text = "$ %d   |   Reputação %.0f   |   Hóspedes %d   |   Lucro $ %d   |   Dia %d • %dx" % [session.economy.cash, session.guests.reputation, session.guest_count(), session.economy.profit(), session.day + 1, session.speed]
	open_button.text = "Fechar chegadas" if session.opened else "Abrir hotel"
	operations.text = session.alerts()
	if debug_label.visible:
		var waiting: int = 0
		var riding: int = 0
		for lift in session.transport.lifts:
			waiting += lift.queue.members.size()
			riding += lift.passengers.size()
		debug_label.text = "FPS %d | Agentes %d | Elevador: fila %d, bordo %d | Rotas %d | Tick %d" % [Engine.get_frames_per_second(), session.actors.size(), waiting, riding, session.transport.path_requests, session.tick_count]
	var actor: ActorState = session.actors.get(actor_id)
	if actor != null:
		inspector.text = "%s\n%s • %s\n\nSatisfação: %.0f\nFome: %.0f\nCansaço: %.0f\nDinheiro: $ %d\nQuarto: %d\nTempo: %.0fs\nEspera: %.1fs\nDestino: andar %d\n\nUtilidades:\n%s" % [actor.display_name, actor.role, actor.state, actor.happiness, actor.needs.hunger, actor.needs.energy, actor.money, actor.bedroom, actor.age, actor.waiting, actor.target_floor, str(actor.utility_scores)]

func _build_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 16
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("203a43")
	panel.content_margin_left = 14
	panel.content_margin_right = 14
	panel.content_margin_top = 14
	panel.content_margin_bottom = 14
	theme.set_stylebox("panel", "PanelContainer", panel)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("35535c") if state == "normal" else Color("496f72")
		box.set_corner_radius_all(7)
		box.content_margin_left = 10
		box.content_margin_right = 10
		if state == "focus":
			box.bg_color = Color.TRANSPARENT
			box.border_color = Color("f7cf79")
			box.set_border_width_all(2)
		theme.set_stylebox(state, "Button", box)
	theme.set_color("font_color", "Label", Color("eef1e5"))
