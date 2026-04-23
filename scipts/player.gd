extends CharacterBody2D

# --- TUS CONSTANTES ORIGINALES (Páginas 6 y 7 del PDF) ---
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const MAX_SPEED = 400.0
const FRICTION = 600.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1200.0
const MAX_FALL_SPEED = 800.0
const WALL_JUMP_VELOCITY = Vector2(400, -500)
const WALL_SLIDE_SPEED = 100.0

var coyote_timer = 0.0
const COYOTE_DURATION = 0.15 # Duración del margen (puedes ajustarlo)

# --- VARIABLES DE VIDA ---
@export var vidas: int = 3
var esta_invulnerable = false

# Variables de movimiento originales
var speed = 0.0
var rings = 0
var is_on_wall_slide = false

func _ready():
	# Sincronización inicial
	if GameManager:
		GameManager.lives = vidas

func _physics_process(delta):
	# Gravedad
	if is_on_floor():
		coyote_timer = COYOTE_DURATION # Mientras toque el suelo, el timer está lleno
	else:
		coyote_timer -= delta # Si está en el aire, el tiempo empieza a correr

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	# Detectar pared
	var is_on_wall_now = is_on_wall()
	if is_on_wall_now and not is_on_floor():
		is_on_wall_slide = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	else:
		is_on_wall_slide = false
	
	# Física de pendientes (Tu lógica de la pág. 6)
	var floor_normal = get_floor_normal()
	var is_on_slope = is_on_floor() and abs(floor_normal.x) > 0.2
	
	# Input
	var input_direction = Input.get_axis("ui_left", "ui_right")
	
	if input_direction != 0:
		speed += input_direction * ACCELERATION * delta
		speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
		$sonic_animations.scale.x = 1 if input_direction > 0 else -1
	else:
		if is_on_slope:
			speed += floor_normal.x * 800.0 * delta
		else:
			if is_on_floor():
				speed = move_toward(speed, 0, FRICTION * delta)
	
	velocity.x = speed
	
	# Saltos
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_wall_slide:
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
			velocity.y = WALL_JUMP_VELOCITY.y
			speed = velocity.x
		elif coyote_timer > 0: # Ahora salta si el timer aún tiene tiempo, no solo si toca el suelo
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0 # Gastamos el timer para que no salte dos veces en el aire
	move_and_slide()
	update_animation()

func update_animation():
	var new_animation = ""
	if is_on_wall_slide or not is_on_floor():
		new_animation = "saltar"
	elif abs(velocity.x) > 10:
		if $sonic_animations.animation != "correr_loop" and $sonic_animations.animation != "acelerar":
			$sonic_animations.play("acelerar")
		elif $sonic_animations.animation == "acelerar" and not $sonic_animations.is_playing():
			$sonic_animations.play("correr_loop")
		return
	else:
		new_animation = "quieto"
	
	if new_animation != "" and $sonic_animations.animation != new_animation:
		$sonic_animations.play(new_animation)

# --- FUNCIÓN DE ANILLOS ---
func collect_ring():
	rings += 1
	if GameManager:
		GameManager.add_ring()

# --- LÓGICA DE DAÑO UNIFICADA (4 GOLPES REALES) ---

func recibir_dano():
	if esta_invulnerable: 
		return
	
	# Si las vidas ya son 0, no permitimos que nada las resetee aquí
	if vidas <= 0:
		print("MUERTE CRÍTICA: Cambiando a Game Over...")
		die()
		return

	# Restamos vida
	vidas -= 1
	
	# Actualizamos el HUD (Importante para tus corazones)
	var hud_node = get_tree().current_scene.find_child("Hud", true, false)
	if hud_node and hud_node.has_method("actualizar_interfaz_vidas"):
		hud_node.actualizar_interfaz_vidas(vidas)
	
	# Sincronizamos con GameManager (solo para que él lo sepa)
	if GameManager:
		GameManager.lives = vidas
	
	print("GOLPE RECIBIDO. Vidas restantes: ", vidas)
	
	if vidas > 0:
		aplicar_efecto_dano()
	else:
		# Si con este golpe llegó a 0, le damos una última oportunidad 
		# de estar vivo (el famoso 4º golpe que pediste)
		aplicar_efecto_dano()
		
	# --- ACTIVAR TEMBLOR ---
	# Como la cámara es hija de Sonic, la llamamos directamente por su nombre
	# Asegúrate de que el nombre coincida (si se llama Camera2D, usa $Camera2D)
	if has_node("Camera2D"):
		$Camera2D.apply_shake(5.0)

func aplicar_efecto_dano():
	# 1. ACTIVAR INVULNERABILIDAD
	esta_invulnerable = true
	
	# 2. SELECCIONAR ANIMACIÓN (Sin cambiar escalas)
	if $sonic_animations.sprite_frames.has_animation("loop"):
		$sonic_animations.play("loop")
	elif $sonic_animations.sprite_frames.has_animation("hurt"):
		$sonic_animations.play("hurt")
	
	# 3. PONER COLOR ROJO
	$sonic_animations.modulate = Color(1, 0, 0) # Rojo
	
	# 4. EFECTO DE RETROCESO (Knockback)
	# Usamos el scale.x actual para saber hacia dónde mirar
	var knockback_dir = -1 if $sonic_animations.scale.x > 0 else 1
	velocity.x = knockback_dir * 300
	velocity.y = -250
	
	# 5. EFECTO VISUAL: PARPADEO (Transparencia)
	# Solo animamos la propiedad "a" (alpha) para no tocar el color rojo
	var tween = create_tween().set_loops(10)
	tween.tween_property($sonic_animations, "modulate:a", 0.2, 0.1)
	tween.tween_property($sonic_animations, "modulate:a", 1.0, 0.1)
	
	# 6. TEMPORIZADOR DE SEGURIDAD
	await get_tree().create_timer(2.0).timeout
	
	# 7. REGRESO A LA NORMALIDAD
	esta_invulnerable = false
	$sonic_animations.modulate = Color(1, 1, 1) # Volvemos al color original (blanco)
	# Nos aseguramos de que el alpha sea 1 por si el tween terminó en 0.2
	$sonic_animations.modulate.a = 1.0 
	print("Sonic ya no es invulnerable")

# Mantenemos hit() pero hacemos que TAMBIÉN llame a recibir_dano si quieres que el Boss sea letal
func hit():
	if rings > 0:
		rings = 0
		if GameManager:
			GameManager.lose_rings()
		# Si quieres que los anillos te protejan de morir, deja esto. 
		# Si quieres morir en 4 golpes SIEMPRE, quita el 'if rings' y deja solo recibir_dano()
		aplicar_efecto_dano() 
	else:
		recibir_dano()

func die():
	var game_over_path = "res://scenes/ui/GameOver.tscn"
	if ResourceLoader.exists(game_over_path):
		get_tree().change_scene_to_file(game_over_path)
	else:
		get_tree().reload_current_scene()
