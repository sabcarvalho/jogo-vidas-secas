class_name Character extends Node3D

@onready var animation_tree : AnimationTree = %AnimationTree

#as funcoes mexem apenas nas variaveis de transicao de estado na arvore de animacao
func idle():
	animation_tree["parameters/conditions/idle"] = true
	animation_tree["parameters/conditions/is_walking"] = false

func move():
	animation_tree["parameters/conditions/idle"] = false
	animation_tree["parameters/conditions/is_walking"] = true

func angry():
	animation_tree["parameters/conditions/angry"] = true
	
func accept():
	animation_tree["parameters/conditions/accept"] = true
