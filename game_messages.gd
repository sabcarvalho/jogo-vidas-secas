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

# Funcoes sinal para as zonas de cura
func _on_area_agua_body_entered(body: Node3D) -> void:
	if body is Fabiano:
		show_text("Bebendo Água...")

func _on_area_agua_body_exited(body: Node3D) -> void:
	if body is Fabiano:
		hide_text()

func _on_area_sombra_body_entered(body: Node3D) -> void:
	if body is Fabiano:
		show_text("Descansando na Sombra...")
		
func _on_area_sombra_body_exited(body: Node3D) -> void:
	if body is Fabiano:
			hide_text()
