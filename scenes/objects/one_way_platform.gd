extends AnimatableBody2D

func _ready():
	# Configurar como plataforma one-way
	collision_layer = 1
	collision_mask = 0
	
	# Habilitar one-way collision manualmente
	for child in get_children():
		if child is CollisionShape2D:
			child.one_way_collision = true
			child.one_way_collision_margin = 1.0
