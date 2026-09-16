class_name HotelView
extends Control
## Original procedural placeholders. This view never changes simulation data.

signal cell_clicked(column: int, floor_index: int)
signal cancelled

const CELL: float = 62.0
const FLOOR_HEIGHT: float = 108.0
var hotel: HotelModel
var selected: int = -1
var blueprint: RoomDefinition
var zoom_factor: float = 1.0
var pan: Vector2 = Vector2.ZERO
var pointer: Vector2 = Vector2(-1000, -1000)
var drag: bool = false
var hovered_cell := Vector2i(-1, -1)

func origin() -> Vector2:
	return Vector2((size.x - HotelModel.COLUMNS * CELL * zoom_factor) / 2.0, size.y - 95) + pan

func world_to_screen(point: Vector2) -> Vector2:
	return origin() + point * zoom_factor

func cell_at(point: Vector2) -> Vector2i:
	var local: Vector2 = (point - origin()) / zoom_factor
	return Vector2i(floori(local.x / CELL), floori(-local.y / FLOOR_HEIGHT))

func room_rect(column: int, floor_index: int, width: int = 1) -> Rect2:
	return Rect2(world_to_screen(Vector2(column * CELL, -(floor_index + 1) * FLOOR_HEIGHT)), Vector2(width * CELL, FLOOR_HEIGHT) * zoom_factor)

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pointer = event.position
		if drag:
			pan += event.relative
		hovered_cell = cell_at(pointer)
		queue_redraw()
	if event is InputEventMouseButton:
		pointer = event.position
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			drag = event.pressed
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var cell := cell_at(pointer)
			cell_clicked.emit(cell.x, cell.y)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancelled.emit()
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var previous: Vector2 = (pointer - origin()) / zoom_factor
			zoom_factor = clampf(zoom_factor * (1.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.1), 0.35, 1.8)
			pan += pointer - world_to_screen(previous)
			queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("d7e6e4"))
	_draw_skyline()
	if hotel == null:
		return
	var ground: Vector2 = origin()
	draw_rect(Rect2(Vector2(0, ground.y + 8), Vector2(size.x, maxf(0, size.y - ground.y))), Color("7b9a7e"))
	draw_line(Vector2(0, ground.y + 6), Vector2(size.x, ground.y + 6), Color("bdc9b2"), 12)
	for level in hotel.floors:
		var floor_rect := room_rect(0, level, HotelModel.COLUMNS)
		draw_rect(floor_rect, Color("edf0e7"))
		for column in HotelModel.COLUMNS:
			draw_rect(room_rect(column, level), Color("c7d3cc"), false, 1)
		draw_line(floor_rect.end, Vector2(floor_rect.position.x, floor_rect.end.y), Color("576b68"), 5 * zoom_factor)
		_text(floor_rect.position + Vector2(-35, 25), "T" if level == 0 else str(level), Color("455d5c"), 16)
	for room in hotel.rooms:
		_draw_room(room)
	if blueprint != null:
		var cell := cell_at(pointer)
		var valid: bool = hotel.build_error(blueprint, cell.x, cell.y).is_empty()
		var preview := room_rect(cell.x, cell.y, blueprint.width)
		var tint := Color(0.1, 0.65, 0.36, 0.45) if valid else Color(0.9, 0.22, 0.2, 0.5)
		draw_rect(preview, tint)
		draw_rect(preview, tint.lightened(0.2), false, 3)
		_text(preview.position + Vector2(8, 22), "+" if valid else "×", Color.WHITE, 20)
	_text(Vector2(22, 30), "SEU HOTEL, UM ANDAR DE CADA VEZ", Color("55716e"), 14)
	_text(Vector2(22, size.y - 22), "Scroll: zoom   •   Botão do meio: mover   •   Clique direito / Esc: cancelar", Color("f1f5e9"), 14)

func _draw_skyline() -> void:
	for index in 12:
		var height: float = 100.0 + float((index * 47) % 140)
		var rectangle := Rect2(index * 125.0 - 15.0, size.y - height - 90, 88, height)
		draw_rect(rectangle, Color("c1d5d1"))
		for row in int(height / 25):
			for col in 3:
				draw_rect(Rect2(rectangle.position + Vector2(12 + col * 24, 12 + row * 25), Vector2(10, 12)), Color("d1e0d9"))

func _draw_room(room: RoomState) -> void:
	var definition := room.definition()
	var rectangle := room_rect(room.column, room.floor_index, definition.width).grow(-3 * zoom_factor)
	if definition.category == &"transport":
		rectangle = room_rect(room.column, hotel.floors - 1, 1)
		rectangle.size.y = hotel.floors * FLOOR_HEIGHT * zoom_factor
		draw_rect(rectangle.grow(-3), Color("788691"))
		for level in hotel.floors:
			var door := room_rect(room.column, level).grow(-12 * zoom_factor)
			draw_rect(door, Color("aebdc5"))
			draw_line(door.get_center() - Vector2(0, door.size.y / 2), door.get_center() + Vector2(0, door.size.y / 2), Color("566773"), 2)
	else:
		draw_rect(rectangle, definition.color.lightened(0.35))
		draw_rect(Rect2(rectangle.position, Vector2(rectangle.size.x, 26 * zoom_factor)), definition.color.darkened(0.25))
		var base: Vector2 = rectangle.position + Vector2(14, 48) * zoom_factor
		if definition.category == &"lodging":
			draw_rect(Rect2(base, Vector2(65, 32) * zoom_factor), Color("fff7de"))
			draw_rect(Rect2(base + Vector2(20, 0) * zoom_factor, Vector2(45, 32) * zoom_factor), definition.color)
		elif definition.category == &"reception":
			draw_rect(Rect2(base + Vector2(5, 10) * zoom_factor, Vector2(115, 25) * zoom_factor), Color("566c59"))
			draw_circle(base + Vector2(55, 0) * zoom_factor, 9 * zoom_factor, Color("eed5b3"))
		else:
			for i in 3:
				draw_circle(base + Vector2(22 + i * 48, 15) * zoom_factor, 15 * zoom_factor, Color("f8e6bc"))
		if zoom_factor >= 0.65:
			_text(rectangle.position + Vector2(7, 19) * zoom_factor, definition.display_name, Color.WHITE, int(13 * zoom_factor))
	if room.id == selected:
		draw_rect(rectangle, Color("f9cd69"), false, 4)

func _text(at: Vector2, value: String, color: Color, font_size: int) -> void:
	draw_string(ThemeDB.fallback_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
