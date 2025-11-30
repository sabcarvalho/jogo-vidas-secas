#Classe de controle da cutscene final
class_name Controlador extends Node

@export var soldado : Soldado
@export var fade : AnimationPlayer
@onready var fabiano : Fabiano = %Fabiano
@onready var som_tiro = %som_tiro

@export_group("Cameras")
@export var camera1 : Camera3D
@export var camera2 : Camera3D
@export var camera3 : Camera3D
@export var camera4 : Camera3D
@export var camera5 : Camera3D

var aceitou : bool = false

func _ready() -> void:
	#conectando ao pluggin de dialogo
	Dialogic.signal_event.connect(_on_dialogic_signal)
	#primeira camera ligada
	camera1.make_current()

#funcao chamada pelo Soldado quando chega no ponto 1
func start():
	#mudanca para a camera do soldado
	camera2.make_current()
	#comeco do dialogo
	Dialogic.start("timeline")

#funcao chamada ao dialogo criar algum sinal (ver o doc de dialogo)
func _on_dialogic_signal(arg : String):
	#checagem do parametro recebido
	if arg == "player":
		#mudanca para a camera do Fabiano
		camera3.make_current()
	elif arg == "soldado":
		#mudanca para a camera do soldado
		camera2.make_current()
	elif arg == "aceitou":
		#o player abaixou a cabeca
		fabiano.accept() #toca animacao de baixar a cabeca
		aceitou = true #seta variavel
	elif arg == "enfrentou":
		#o player escolheu enfrentar o soldado
		fabiano.angry() #toca animacao de raiva
		aceitou = false #seta variavel
	elif arg == "fim":
		#acabou o dialogo
		if aceitou: #se o player abaixou a cabeça
			camera4.make_current() #muda a camera
			soldado.active_walk() #soldado anda ate o ponto 2
		else:
			#final ruim
			fade.play("fade_out") #escurece a tela
			bad_ending()
#funcao chamada pelo soldado ao chegar no ponto 2
func good_ending():
	#fabiano anda ate o ponto 3
	fabiano.set_walk()
	#mudanca de camera
	camera5.make_current()
	
func bad_ending():
	som_tiro.play()
