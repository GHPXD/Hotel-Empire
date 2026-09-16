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

func _ready() -> void:
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
	hotel.changed.connect(_refresh)
	_refresh()

func _process(delta: float) -> void:
	accumulator += minf(delta, 0.25) * session.speed
	while accumulator >= session.rules.tick:
		session.tick(session.rules.tick)
		accumulator -= session.rules.tick
	ui_timer += delta
	view.queue_redraw()
	if ui_timer >= 0.2:
		ui_timer = 0
		_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_cancel()

func _on_build_requested(definition: RoomDefinition) -> void:
	view.blueprint = definition
	hud.message.text = "Construir %s • $ %d • clique numa posição livre." % [definition.display_name, definition.build_cost]
	view.queue_redraw()

func _on_cell_clicked(column: int, floor_index: int) -> void:
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

func _hire(definition: EmployeeDefinition) -> void:
	var error := session.hire(definition)
	hud.message.text = "%s contratado(a). Atribuição automática; salário $ %d/dia." % [definition.display_name, definition.salary] if error.is_empty() else error
	_refresh()

func _select_actor(id: int) -> void:
	selected_actor = id
	selection = -1
	_refresh()
