extends Camera2D

# --- VARIABLES ---
var shake_strength: float = 0.0
var shake_decay: float = 20.0 

@export var target_path: NodePath # Para asignar a Sonic desde el inspector
var target: Node2D

func _ready():
	# Si no asignaste el target en el inspector, intenta buscar a Sonic
	if target_path:
		target = get_node(target_path)
	else:
		target = get_tree().current_scene.find_child("Sonic", true, false)

func _process(delta):
	# 1. SEGUIMIENTO SUAVE (Smoothing)
	if target:
		# Esto hace que la cámara siga a Sonic suavemente
		global_position = lerp(global_position, target.global_position, 0.1)

	# 2. LÓGICA DEL TEMBLOR (Screenshake)
	if shake_strength > 0:
		# Aplicamos el movimiento aleatorio al offset
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		# Va bajando la intensidad poco a poco
		shake_strength = move_toward(shake_strength, 0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

# Esta función la llamaremos desde Sonic cuando reciba daño
func apply_shake(intensity: float):
	shake_strength = intensity
