class_name Soldado extends CharacterBody3D

#variaveis no inspetor
@export var ponto1 : Node3D
@export var ponto2 : Node3D
@export var speed : float = 2.0
@export var _skin: Character

#copia do controlador (para chama-lo ao chegar nos pontos)
@onready var controlador : Controlador = %Controlador

var walk := true
var target : Node3D

#ao carregar a cena
func _ready():
	#primeiro alvo
	target = ponto1
	#animacao
	_skin.move()

func _physics_process(_delta: float) -> void:
	if walk: #se eh para andar
		var target_pos = target.global_position #posicao do alvo
		target_pos.y = global_position.y  # mantém no chão

		var dir = (target_pos - global_position).normalized()
		velocity = dir * speed
		
		move_and_slide()

		if global_position.distance_to(target_pos) < 1.2: #chegou no ponto
			#para de andar
			walk = false 
			_skin.idle() 
			#zera velocidade
			velocity = Vector3.ZERO 
			
			if target == ponto1: #primeira parada
				controlador.start() #comeca o dialogo
			else:
				controlador.good_ending() #ponto 2 eh o do final bom

func active_walk(): #funcao de ativacao do andar (para o segundo ponto)
	_skin.move()
	target = ponto2
	walk = true
	
