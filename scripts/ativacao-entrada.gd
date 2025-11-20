extends Area3D

@export var baleia : Baleia

func _on_body_entered(body: Node3D) -> void:
	if body is Fabiano: 
		#se o Fabiano passa na area de ativacao, a baleia aparece
		baleia.fade_in()
