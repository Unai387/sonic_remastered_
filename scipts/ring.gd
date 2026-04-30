extends Area2D

var soltado = false
var velocidad = Vector2.ZERO
var tiempo_espera = 0.5 # Para no recogerlo instantáneamente al soltarlo

func _ready():
	body_entered.connect(_on_body_entered)
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()
	elif has_node("AnimatedSprite"):
		$AnimatedSprite.play()

func _physics_process(delta):
	if soltado:
		# Movimiento y gravedad
		position += velocidad * delta
		velocidad.y += 15 
		velocidad *= 0.98 # Rozamiento
		
		# Si pasa tiempo, reducimos la espera para poder recogerlo
		if tiempo_espera > 0:
			tiempo_espera -= delta

func _on_body_entered(body):
	# Si acaba de ser soltado, esperamos un poco antes de dejar que se recoja
	if soltado and tiempo_espera > 0:
		return
		
	if body.name == "Sonic" or body.has_method("collect_ring"):
		body.collect_ring()
		queue_free()
