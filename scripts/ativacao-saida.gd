extends Area3D

@export var baleia : Baleia

func _on_body_entered(body: Node3D) -> void:
	if body is Fabiano:
		#se o Fabiano passa na area de saida, a baleia aparece
		baleia.fade_out()
		#e eh colocada na area do poço
		baleia.position = Vector3(92, 10, 232)
		baleia.rotation_degrees = Vector3(0,-150,0)
