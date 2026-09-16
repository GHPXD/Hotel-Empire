class_name HotelHUD
extends Control

signal build_requested(definition: RoomDefinition)
signal floor_requested
signal demolish_requested
signal cancel_requested

var stats: Label
var message: Label
var inspector: Label
var world_slot: Control

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
	header_row.add_child(stats)
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
	inspector = Label.new()
	inspector.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector.text = "Construa uma recepção no térreo para começar."
	inspector.custom_minimum_size.x = 235
	tools.add_child(inspector)
	var footer := PanelContainer.new()
	layout.add_child(footer)
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.text = "Bem-vindo. Escolha uma sala e clique no terreno."
	footer.add_child(message)

func refresh(hotel: HotelModel, selected: RoomState) -> void:
	stats.text = "$ %s    |    %d andar(es)    |    Investido: $ %d" % [hotel.economy.cash, hotel.floors, hotel.economy.capital_spent]
	if selected != null:
		var definition := selected.definition()
		inspector.text = "%s  #%d\n\nCapacidade: %d\nUsuários: %d\nFila: %d\nReceita: $ %d\nManutenção: $ %d/dia\n\nDemolição sem reembolso." % [definition.display_name, selected.id, definition.capacity, selected.users.size(), selected.queue.members.size(), selected.income, definition.maintenance]
	else:
		inspector.text = "SEU PRIMEIRO HOTEL\n\n1. Recepção no térreo\n2. Quartos para hospedar\n3. Bistrô para refeições\n4. Elevador para expandir\n\nPoços ocupam a mesma coluna em todos os andares."

func _button(parent: Control, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.pressed.connect(action)
	parent.add_child(button)

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
