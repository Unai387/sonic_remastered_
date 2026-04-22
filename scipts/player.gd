extends CharacterBody2D

# Constantes de física estilo Sonic
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const MAX_SPEED = 400.0
const FRICTION = 600.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1200.0
const MAX_FALL_SPEED = 800.0

# Constantes de wall jump
const WALL_JUMP_VELOCITY = Vector2(400, -500)
const WALL_SLIDE_SPEED = 100.0

# Variables
var speed = 0.0
var rings = 0
var is_on_wall_slide = false

func _ready():
	pass

func _physics_process(delta):
	# Detectar si está tocando una pared
	var is_on_wall_now = is_on_wall()
	
	# Wall slide (deslizarse por pared)
	if is_on_wall_now and not is_on_floor():
		is_on_wall_slide = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)  # Caer más lento en pared
	else:
		is_on_wall_slide = false
	
	# Aplicar gravedad normal
	if not is_on_floor() and not is_on_wall_slide:
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Input horizontal
	var input_direction = Input.get_axis("ui_left", "ui_right")
	
	# Wall Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_wall_slide:
		var wall_normal = get_wall_normal()
		velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
		velocity.y = WALL_JUMP_VELOCITY.y
		speed = velocity.x
	# Salto normal
	elif Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Movimiento horizontal (solo si no está en wall jump)
	if not is_on_wall_slide or is_on_floor():
		if input_direction != 0:
			# Acelerar
			speed += input_direction * ACCELERATION * delta
			speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
			
			# Voltear sprite según dirección
			if input_direction > 0:
				$sonic_animations.scale.x = 1
			else:
				$sonic_animations.scale.x = -1
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
	
	move_and_slide()
	
	# Actualizar animación
	update_animation()

func update_animation():
	var new_animation = ""
	
	if is_on_wall_slide:
		new_animation = "saltar"
	elif not is_on_floor():
		new_animation = "saltar"
	elif abs(velocity.x) > 10:
		# Si está acelerando, reproducir "acelerar"
		if $sonic_animations.animation != "correr_loop" and $sonic_animations.animation != "acelerar":
			$sonic_animations.play("acelerar")
		# Cuando termine "acelerar", pasar a "correr_loop"
		elif $sonic_animations.animation == "acelerar" and not $sonic_animations.is_playing():
			$sonic_animations.play("correr_loop")
		# Si ya está en correr_loop, mantenerlo
		return
	else:
		new_animation = "quieto"
	
	# Solo cambiar si es diferente
	if new_animation != "" and $sonic_animations.animation != new_animation:
		$sonic_animations.play(new_animation)

func collect_ring():
	rings += 1
	GameManager.add_ring()

func hit():
	if rings > 0:
		rings = 0
		GameManager.lose_rings()
	else:
		die()

func die():
	var game_over_scene = load("res://scenes/ui/GameOver.tscn")
	var game_over = game_over_scene.instantiate()
	get_tree().root.add_child(game_over)
	get_tree().paused = true
	game_over.process_mode = Node.PROCESS_MODE_ALWAYS
