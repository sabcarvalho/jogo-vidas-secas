extends Node3D

@onready var pause_menu = $pause_menu

@onready var game_messages = $CanvasLayer/GameMessages
var paused = false
func _ready() -> void:
	# Garante que o jogo começa rodando normalmente
	Engine.time_scale = 1.0
	paused = false
	pause_menu.hide()
	
	if game_messages:
		game_messages.hide_message()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
