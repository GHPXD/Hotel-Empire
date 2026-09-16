extends Node

func _ready() -> void:
	var label := Label.new()
	label.text = "HOTEL EMPIRE\nFundação da simulação • Godot 4.7"
	label.position = Vector2(64, 64)
	label.add_theme_font_size_override("font_size", 32)
	add_child(label)
