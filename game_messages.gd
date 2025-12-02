extends Control

@onready var label = $MessageLabel

func _ready() -> void:
	# comeca com o texto escondido
	label.text = ""
	label.visible = false

func show_text(text: String):
	label.text = text
	label.visible = true

func hide_text():
	label.text = ""
	label.visible = false
