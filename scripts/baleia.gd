class_name Baleia extends Node3D

@onready var animation_tree : AnimationTree = %AnimationTree

#as funcoes mexem apenas nas variaveis de transicao de estado na arvore de animacao
func fade_in():
	animation_tree["parameters/conditions/out"] = false
	animation_tree["parameters/conditions/reset"] = true

func fade_out():
	animation_tree["parameters/conditions/reset"] = false
	animation_tree["parameters/conditions/out"] = true
