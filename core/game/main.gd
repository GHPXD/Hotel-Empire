extends Node

var economy := HotelEconomy.new()
var hotel := HotelModel.new(economy)
var view: HotelView
var hud: HotelHUD
var selection: int = -1

func _ready() -> void:
	hud = HotelHUD.new()
	add_child(hud)
	view = HotelView.new()
	view.hotel = hotel
	hud.world_slot.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.cell_clicked.connect(_on_cell_clicked)
	view.cancelled.connect(_cancel)
	hud.build_requested.connect(_on_build_requested)
	hud.floor_requested.connect(_add_floor)
	hud.cancel_requested.connect(_cancel)
	hud.demolish_requested.connect(_demolish)
	hotel.changed.connect(_refresh)
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
	var error := hotel.demolish(selection)
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
