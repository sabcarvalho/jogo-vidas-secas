class_name Status extends Control

#barras de sede e calor
@export var sede_bar : ProgressBar
@export var calor_bar : ProgressBar

#timers de 1s
@onready var sede_timer :Timer = $SedeTimer 
@onready var calor_timer :Timer = $CalorTimer

#copia do personagem
@export var fabiano : Fabiano

#variaveis padroes para as barras (da para modificar no inspetor)
#usadas para voltar ao normal apos sair das areas de healing
@export var defaultSede : int = 3
@export var defaultCalor : int = 5

#variaveis que sao usadas nas barras
@onready var sedeDecrease : int = defaultSede
@onready var calorIncrease : int = defaultCalor

func _ready() ->void:
	_refresh_sede()
	_refresh_calor()

#atualizacao no hud
func _refresh_sede():
	sede_bar.value = fabiano.sede
func _refresh_calor():
	calor_bar.value = fabiano.calor


func change_sede(changeValue: int):
	fabiano.sede -= changeValue #decrementa
	fabiano.sede = clamp(fabiano.sede, 0, 100) #limita entre 0 e 100
	
	_refresh_sede() #atualiza
	
func change_calor(changeValue: int):
	fabiano.calor += changeValue #aumenta o calor
	fabiano.calor = clamp(fabiano.calor, 0, 100) #limita entre 0 e 100
	
	_refresh_calor() #atualiza

#funcoes chamadas a cada segundo pelos timers
func _on_sede_timer_timeout() -> void:
	change_sede(sedeDecrease)

func _on_calor_timer_timeout() -> void:
	change_calor(calorIncrease)
