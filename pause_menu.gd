extends Control

@onready var sertao = get_parent()

func _on_continuar_pressed() -> void:
	sertao.pauseMenu()

func _on_quit_pressed() -> void:
	get_tree().quit()
