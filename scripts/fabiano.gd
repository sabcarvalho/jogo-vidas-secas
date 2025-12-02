class_name Fabiano extends CharacterBody3D

@export_group("Cutscene")
@export var cutscene : bool
@export var target : Node3D

@export_group("HUD")
@export var sede = 100
@export var calor = 0
@export var hud : Status
@export var canvas : CanvasLayer

#sensibilidade do mouse disponivel no inspetor
@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25

#velocidade e aceleracao disponiveis no inspetor
@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0


var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var current_move_dir := Vector3.ZERO

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Character = %fabiano

var gravity = -30.0
var walk : bool = false

func _ready() -> void:
	if cutscene:
		#se eh cutscene, tira o HUD
		remove_child(canvas)

#detectando se o mouse esta ou nao na tela
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"): #ao clicar na tela, o mouse some
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"): #ao pressionar esc o mouse reaparece
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and  #se o mouse se moveu
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED #e esta capturado no jogo
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity #mover camera

func _physics_process(delta: float) -> void:
	if cutscene:
		if walk: #andar ate o ponto colocado no inspetor
			handle_cutscene_walk(delta)
		return #ao recebe input do player
	
	#y do input: cima/baixo -> rotacao no eixo x
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	#limitacao de rotacao no eixo x (para nao ficar de cabeca para baixo)
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI/6.0, PI/3.0)
	#x do input: dir/esq -> rotacao no eixo y
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	#limpa o input
	_camera_input_direction = Vector2.ZERO
	
	#direcao frente eh o z da camera
	var forward := _camera.global_basis.z
	#direcao direita eh o x da camera
	var right := _camera.global_basis.x
	#captura o movimento do jogador a partir das teclas
	#esq : x = -1
	#dir: x = 1
	#cima: y = 1
	#baixo: y = -1
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#se y = 1, mover para frente
	#se x = 1, mover para direita
	var move_direction := forward * raw_input.y + right * raw_input.x
	
	move_direction.y = 0.0 #sem movimento na vertical 
	
	move_direction = move_direction.normalized() 
	
	#velocidade eh calculada pela direcao do input, 
	#multiplicada pela velocidade pre-determinada
	velocity = velocity.move_toward(move_direction*move_speed, acceleration*delta)
	velocity.y += gravity*delta #gravidade
	
	#mover o personagem de acordo com a velocidade calculada e 
	#aplicar a física de colisão
	move_and_slide() 
	
	
	if move_direction.length() > 0.2: #se ha movimento
		#guarda
		_last_movement_direction = move_direction 
		current_move_dir = move_direction
		
		#toca animacao de movimento
		_skin.move() 
	else:
		#zera a movimentacao atual
		current_move_dir = Vector3.ZERO
		#toca animacao de idle
		_skin.idle()
	
	#rotacao para o personagem olhar em direcao ao movimento
	var target_angle := Vector3.BACK.signed_angle_to(
		_last_movement_direction, Vector3.UP
	)
	#aplica rotacao na skin
	_skin.global_rotation.y = target_angle

#funcao chamada ao entrar na area de sombra
func _on_healing_calor_body_entered(body: Node3D) -> void:
	if body == self: 
		hud.sedeDecrease = 0 # para de sentir sede na sombra
		hud.calorIncrease = -5

#funcao chamada ao sair da area de sombra
func _on_healing_calor_body_exited(body: Node3D) -> void:
	if body == self:
		hud.sedeDecrease = hud.defaultSede
		hud.calorIncrease = hud.defaultCalor

#funcao chamada ao entrar na area do poço
func _on_area_agua_body_entered(body: Node3D) -> void:
	if body == self:
		hud.sedeDecrease = -10
		hud.calorIncrease = 0 # o calor para de subir

#funcao chamada ao sair da area do poço
func _on_area_agua_body_exited(body: Node3D) -> void:
	if body == self:
		hud.sedeDecrease = hud.defaultSede
		hud.calorIncrease = hud.defaultCalor

#funcao chamada ao entrar na area final
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		call_deferred("_mudar_cena")

#carrega a cena final
func _mudar_cena():
	get_tree().change_scene_to_file("res://fim.tscn")

#funcao para indicar a rotacao do personagem para os npcs
func get_skin_rotation() -> float:
	return _skin.global_rotation.y

#funcoes de acesso a mudanca de animacoes na cena final
func accept():
	_skin.accept()
func angry():
	_skin.angry()

#funcao chamada para mover na cutscene
func set_walk():
	_skin.move()
	walk = true

#andando ate um ponto na cutscene
func handle_cutscene_walk(_delta):
	if !walk:
		return
	
	#posicao do ponto
	var target_pos = target.global_position 
	#colocando a mesma coordenada em y para nao andar na vertical
	target_pos.y = global_position.y 
	
	#calculando o vetor de direcao ate o ponto
	var dir = (target_pos - global_position).normalized()
	#direcao eh ponderada pela velocidade
	velocity = dir * move_speed
	current_move_dir = dir #guarda a direcao para os npcs
	move_and_slide() #move
	
	#chegou no ponto
	if global_position.distance_to(target_pos) < 1.2:
		#para de andar e para a animacao
		walk = false
		_skin.idle()
		velocity = Vector3.ZERO
