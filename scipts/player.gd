extends CharacterBody2D

# Constantes de física estilo Sonic
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const MAX_SPEED = 400.0
const FRICTION = 600.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1200.0
const MAX_FALL_SPEED = 800.0

# Variables
var speed = 0.0
var rings = 0

func _ready():
	pass

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Input horizontal
	var input_direction = Input.get_axis("ui_left", "ui_right")
	
	if input_direction != 0:
		# Acelerar
		speed += input_direction * ACCELERATION * delta
		speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
		
		# Voltear sprite según dirección
		if input_direction > 0:
			$Visual.scale.x = 1
		else:
			$Visual.scale.x = -1
	else:
		# Desacelerar con fricción
		if is_on_floor():
			if abs(speed) > 0:
				var decel = FRICTION * delta
				if speed > 0:
					speed = max(0, speed - decel)
				else:
					speed = min(0, speed + decel)
	
	velocity.x = speed
	
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()

func collect_ring():
	rings += 1
	GameManager.add_ring()

func hit():
	if rings > 0:
		# Perder anillos
		rings = 0
		GameManager.lose_rings()
	else:
		# Game over
		die()

func die():
	# Reiniciar nivel
	get_tree().reload_current_scene()
