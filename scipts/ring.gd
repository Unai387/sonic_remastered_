extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	if has_node("AnimatedSprite"):
		$AnimatedSprite.play()
	elif has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()

func _on_body_entered(body):
	# Si el que toca el anillo es Sonic...
	if body.name == "Sonic":
		# 1. Sumamos el anillo en el script de Sonic
		if body.has_method("collect_ring"):
			body.collect_ring()
		
		# 2. Buscamos el HUD y le decimos que se actualice
		# Buscamos "Hud" en toda la escena actual
		var hud = get_tree().current_scene.find_child("Hud", true, false)
		if hud:
			hud.actualizar_interfaz_anillos(body.rings)
		
		# 3. Borramos el anillo
		queue_free()
