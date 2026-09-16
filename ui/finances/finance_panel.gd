class_name FinancePanel
extends Window

var details: RichTextLabel
var dialog_text: String = "":
	set(value):
		dialog_text = value
		if details != null:
			details.text = value

func _ready() -> void:
	title = "Finanças do hotel"
	size = Vector2i(600, 520)
	min_size = Vector2i(430, 320)
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
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.focus_mode = Control.FOCUS_ALL
	details.text = dialog_text
	column.add_child(details)
	var close := Button.new()
	close.text = "Fechar • Esc"
	close.custom_minimum_size.y = 42
	close.pressed.connect(hide)
	column.add_child(close)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		set_input_as_handled()
