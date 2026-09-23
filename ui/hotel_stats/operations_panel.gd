class_name OperationsPanel
extends Window

signal room_requested(id: int)
signal filters_changed
var summary_label: Label
var category_choice: OptionButton
var floor_choice: OptionButton
var status_choice: OptionButton
var room_list: ItemList
var count_label: Label
var inspect_button: Button
var selected_details: Label
var rows: Array[Dictionary] = []
const CATEGORIES: Array[StringName] = [&"", &"lodging", &"reception", &"service", &"transport"]

func _ready() -> void:
	title = "Operação do hotel"
	size = Vector2i(760, 650)
	min_size = Vector2i(500, 560)
	hide()
	close_requested.connect(hide)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(summary_label)
	var filters := HFlowContainer.new()
	column.add_child(filters)
	category_choice = _choice(filters, "Tipo de sala", ["Todas as salas", "Quartos", "Recepções", "Serviços", "Elevadores"])
	floor_choice = _choice(filters, "Andar", ["Todos os andares"])
	status_choice = _choice(filters, "Situação", ["Qualquer situação", "Com fila", "Precisa limpar", "Em uso"])
	count_label = Label.new()
	count_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(count_label)
	room_list = ItemList.new()
	room_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	room_list.custom_minimum_size.y = 100
	room_list.item_selected.connect(func(_index: int) -> void: filters_changed.emit())
	room_list.item_activated.connect(func(_index: int) -> void: _inspect())
	column.add_child(room_list)
	selected_details = Label.new()
	selected_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var details_scroll := ScrollContainer.new()
	details_scroll.custom_minimum_size.y = 145
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	details_scroll.focus_mode = Control.FOCUS_ALL
	column.add_child(details_scroll)
	details_scroll.add_child(selected_details)
	inspect_button = Button.new()
	inspect_button.text = "Inspecionar sala selecionada"
	inspect_button.custom_minimum_size.y = 42
	inspect_button.pressed.connect(_inspect)
	column.add_child(inspect_button)
	var close := Button.new()
	close.text = "Fechar • Esc"
	close.custom_minimum_size.y = 42
	close.pressed.connect(hide)
	column.add_child(close)

func _choice(parent: Control, label_text: String, items: Array) -> OptionButton:
	var group := VBoxContainer.new()
	parent.add_child(group)
	var label := Label.new()
	label.text = label_text
	group.add_child(label)
	var choice := OptionButton.new()
	choice.custom_minimum_size.y = 38
	for item: String in items:
		choice.add_item(item)
	choice.item_selected.connect(func(_index: int) -> void: filters_changed.emit())
	group.add_child(choice)
	return choice

func open_for(session: HotelSession) -> void:
	refresh(session)
	popup_centered()
	category_choice.grab_focus()

func reset_filters() -> void:
	category_choice.select(0)
	floor_choice.select(0)
	status_choice.select(0)
	room_list.clear()
	rows.clear()

func refresh(session: HotelSession) -> void:
	var metrics := HotelAnalytics.summary(session)
	summary_label.text = "HOTEL INTEIRO • AGORA\nOcupação: %d/%d quartos (%.0f%%) • Limpeza pendente: %d\nFilas: %d nas salas, %d nos elevadores • Maior espera atual: %.1fs\nHóspedes: %d • Equipe: %d • Satisfação dos presentes: %s\nCusto fixo: $ %d/dia • Lucro acumulado: $ %d" % [metrics.occupied, metrics.beds, metrics.occupancy, metrics.dirty, metrics.room_queue, metrics.lift_queue, metrics.longest_wait, metrics.guests, metrics.staff, "—" if metrics.guests == 0 else "%.0f/100" % metrics.happiness, metrics.costs.total, session.economy.profit()]
	if floor_choice.item_count != session.hotel.floors + 1:
		var previous: int = floor_choice.selected
		floor_choice.clear()
		floor_choice.add_item("Todos os andares")
		for level in session.hotel.floors:
			floor_choice.add_item("Térreo" if level == 0 else "Andar %d" % level)
		floor_choice.select(clampi(previous, 0, floor_choice.item_count - 1))
	var selected_id: int = -1
	if not room_list.get_selected_items().is_empty():
		selected_id = int(room_list.get_item_metadata(room_list.get_selected_items()[0]))
	var updated := HotelAnalytics.rooms(session, CATEGORIES[category_choice.selected], floor_choice.selected - 1, status_choice.selected)
	var same_ids: bool = updated.size() == rows.size()
	if same_ids:
		for index in updated.size():
			if updated[index].id != rows[index].id:
				same_ids = false
	rows = updated
	if not same_ids:
		room_list.clear()
	var found: bool = false
	selected_details.text = "Selecione uma sala para ver andar, situação e receita."
	for index in rows.size():
		var row: Dictionary = rows[index]
		var location: String = "todos os andares" if row.transport else ("térreo" if row.floor == 0 else "andar %d" % row.floor)
		var status: String = "LIMPAR" if row.dirty else ("em uso" if row.occupied else "livre")
		if not row.checkin_reason.is_empty():
			status = "com fila" if row.queue > 0 else "sem fila"
		var text: String = "#%d %s • %s • %s • fila %d" % [row.id, row.name, location, status, row.queue]
		var details: String = "%s\nNível %d • Receita acumulada: $ %d" % [text, row.level, row.income]
		if not row.checkin_reason.is_empty():
			details += "\nCheck-in: " + UILabels.checkin(row.checkin_reason)
		if not row.lift_metrics.is_empty():
			details = "%s • N%d\n%s" % [text, row.level, UILabels.elevator(row.lift_metrics)]
		if not same_ids:
			room_list.add_item("#%d %s • fila %d" % [row.id, row.name, row.queue])
		else:
			room_list.set_item_text(index, "#%d %s • fila %d" % [row.id, row.name, row.queue])
		room_list.set_item_metadata(index, row.id)
		room_list.set_item_tooltip(index, details)
		if row.id == selected_id:
			room_list.select(index)
			found = true
			selected_details.text = details
	inspect_button.disabled = not found
	count_label.text = "%d sala(s) • maior fila primeiro • Enter para inspecionar" % rows.size() if not rows.is_empty() else "Nenhuma sala corresponde aos filtros."

func _inspect() -> void:
	var selected := room_list.get_selected_items()
	if selected.is_empty():
		return
	var id: int = int(room_list.get_item_metadata(selected[0]))
	hide()
	room_requested.emit(id)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		set_input_as_handled()
