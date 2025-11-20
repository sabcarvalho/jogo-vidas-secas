#esse script:
#cria um terreno procedural usando noise

@tool 
extends MeshInstance3D

var _static_body: StaticBody3D
var _collider: CollisionShape3D

@export_range(256.0,10000.0,4.0) var size := 256.0:
	set(new_size):
		size = new_size
		update_mesh()

#variavel resolucao: divisão do terreno/num de poligonos
@export_range(4.0,256.0,4.0) var resolution := 32.0: 
	set(new_resolution):
		resolution = new_resolution
		update_mesh()

#variavel height: altura max dos vales/picos
@export_range(4.0,128.0,4.0) var height := 64.0:
	set(new_height):
		height = new_height
		update_mesh()

#noise: cria os vales e picos
@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)

func _ready() -> void:
	_ensure_collision_nodes()
	update_mesh()

func _ensure_collision_nodes() -> void:
	if _static_body == null:
		_static_body = StaticBody3D.new()
		_static_body.name = "TerrainStaticBody"
		add_child(_static_body)
	if _collider == null:
		_collider = CollisionShape3D.new()
		_static_body.add_child(_collider)

#calcula a altura no ponto: o get_noise dá um numero de -1 a 1
func get_height(x: float, z:float) -> float:
	return noise.get_noise_2d(x,z) * height

#calcula as normais para que a luz funcione corretamente no terreno
func get_normal(x:float, z:float) -> Vector3:
	var epsilon := size/resolution #distancia entre os centros dos poligonos
	#para a normal, calcula a diferenca entre os pontos próximos
	#e define a inclinacao em x e z
	var normal := Vector3( 
		-(get_height(x+epsilon, z) - get_height(x-epsilon,z)) /(2.0 * epsilon),
		1.0, #eh sempre para cima
		-(get_height(x, z+epsilon) - get_height(x,z-epsilon)) /(2.0 * epsilon)
	)
	return normal.normalized()

func update_mesh() -> void:
	_ensure_collision_nodes()
	#criando o plano
	var plane = PlaneMesh.new()
	#subdivide o plano com a var resolution
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)
	
	#arrays internos da mesh
	var plane_arrays = plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	var normal
	var vertex
	var tangent
	
	#para cada vertice original do plano
	for i in range(vertex_array.size()):
		vertex = vertex_array[i]
		normal = Vector3.UP
		tangent = Vector3.RIGHT
		#se tem noise
		if noise:
			#nova altura
			vertex.y = get_height(vertex.x, vertex.z)
			#nova normal
			normal = get_normal(vertex.x, vertex.z)
			#tangente aproximada (prod vetorial entre a normal e o up do mundo
			tangent = normal.cross(Vector3.UP)
		
		#redefinindo as coordenadas do vertice
		vertex_array[i] = vertex
		#redefine a normal
		normal_array[i] = normal
		
		#redefine a inclinacao (COM A CORREÇÃO)
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z
		tangent_array[4 * i + 3] = 1.0 
		
	#cria uma nova mesh
	var array_mesh = ArrayMesh.new()
	#preenche a mesh com os vertices calculados 
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	#substitui a mesh
	mesh = array_mesh
	
	var faces = array_mesh.get_faces()  
	
	var static_body := StaticBody3D.new()
	add_child(static_body)

	var collision_shape = ConcavePolygonShape3D.new()
	collision_shape.set_faces(faces)

	_collider.shape = collision_shape
	
	_static_body.collision_layer = 2
	
