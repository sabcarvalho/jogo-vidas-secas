extends CharacterBody3D
#classe para movimentacao dos npcs (segue o fabiano)
@export var player : Fabiano
@export var skin : Character
@export var follow_speed := 6.0
@export var follow_distance := 2.0 
@export var acceleration := 10.0

var gravity = -30.0

func _physics_process(delta):
	velocity.y += gravity*delta #aplicando a gravidade
	
	if player == null: 
		#apenas para nao quebrar se o player nao foi instanciado
		skin.idle()
		return
	
	#pega a direcao do player
	#(para que os npcs mantenham suas posicoes, se nao, vao todos 
	#convergir em direcao ao player)
	var player_dir = player.current_move_dir.normalized()
	
	#calcula a distancia entre o npc e o player
	var to_player_dir = (player.global_position - global_position)
	to_player_dir.y = 0 #so o eixo horizontal
	
	var distance_to_player = to_player_dir.length() #a norma do vetor distancia
	
	#se o player nao se moveu ou o npc esta perto o sufuciente
	if player_dir == Vector3.ZERO or distance_to_player <= follow_distance:
		#velocidade eh zero
		velocity = velocity.move_toward(Vector3.ZERO, acceleration * delta)
		#animacao de idle
		skin.idle()
		move_and_slide()
		return
	
	
	var move_dir = player_dir
	move_dir.y = 0
	move_dir = move_dir.normalized()
	#velocidade eh o vetor de direcao do player
	velocity = velocity.move_toward(move_dir * follow_speed, acceleration * delta)
	
	move_and_slide()
	
	#rotacao e animacao
	skin.global_rotation.y = player.get_skin_rotation() 
	skin.move()
