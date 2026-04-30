extends CharacterBody2D

# --- TUS CONSTANTES ORIGINALES ---
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const MAX_SPEED = 400.0
const FRICTION = 600.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1200.0
const MAX_FALL_SPEED = 800.0
const WALL_JUMP_VELOCITY = Vector2(400, -500)
const WALL_SLIDE_SPEED = 100.0

# --- PRELOAD DEL ANILLO ---
# Asegúrate de que esta ruta sea la correcta en tu proyecto
@onready var RingScene = preload("res://scenes/objects/ring.tscn")

var coyote_timer = 0.0
const COYOTE_DURATION = 0.15 

# --- VARIABLES DE VIDA Y ANILLOS ---
@export var vidas: int = 3
var esta_invulnerable = false
var speed = 0.0
var rings = 0
var is_on_wall_slide = false

func _ready():
	if GameManager:
		GameManager.lives = vidas

func _physics_process(delta):
	# Gravedad
	if is_on_floor():
		coyote_timer = COYOTE_DURATION 
	else:
		coyote_timer -= delta 

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
	
	# Física de pendientes
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
		elif coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0 
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

# --- FUNCIONES DE ANILLOS ---

func collect_ring():
	rings += 1
	actualizar_hud_anillos()
	if GameManager:
		GameManager.add_ring()

func soltar_anillos_al_aire():
	var cantidad = min(rings, 15) # Soltamos máximo 15 para no saturar
	for i in range(cantidad):
		var nuevo_ring = RingScene.instantiate()
		get_parent().add_child(nuevo_ring) # Lo añadimos al nivel
		nuevo_ring.global_position = global_position
		
		# Física de explosión
		var angulo = randf_range(0, TAU)
		var fuerza = randf_range(200, 450)
		
		# Pasamos los datos al script del anillo
		if "soltado" in nuevo_ring:
			nuevo_ring.soltado = true
			nuevo_ring.velocidad = Vector2(cos(angulo), sin(angulo)) * fuerza

func actualizar_hud_anillos():
	var hud_node = get_tree().current_scene.find_child("Hud", true, false)
	if hud_node:
		hud_node.actualizar_interfaz_anillos(rings)

# --- LÓGICA DE DAÑO ---

func recibir_dano():
	if esta_invulnerable: return
	
	if vidas <= 0:
		die()
		return

	vidas -= 1
	
	var hud_node = get_tree().current_scene.find_child("Hud", true, false)
	if hud_node and hud_node.has_method("actualizar_interfaz_vidas"):
		hud_node.actualizar_interfaz_vidas(vidas)
	
	if GameManager:
		GameManager.lives = vidas
	
	aplicar_efecto_dano()
	
	if has_node("Camera2D"):
		$Camera2D.apply_shake(5.0)

func hit():
	if esta_invulnerable: return
	
	if rings > 0:
		soltar_anillos_al_aire() # ¡Ahora salen volando!
		rings = 0
		actualizar_hud_anillos()
		if GameManager:
			GameManager.lose_rings()
		aplicar_efecto_dano()
	else:
		recibir_dano()

func aplicar_efecto_dano():
	esta_invulnerable = true
	
	if $sonic_animations.sprite_frames.has_animation("loop"):
		$sonic_animations.play("loop")
	
	# Retroceso
	var knockback_dir = -1 if $sonic_animations.scale.x > 0 else 1
	velocity.x = knockback_dir * 300
	velocity.y = -250
	
	# Parpadeo
	var tween = create_tween().set_loops(10)
	tween.tween_property($sonic_animations, "modulate:a", 0.2, 0.1)
	tween.tween_property($sonic_animations, "modulate:a", 1.0, 0.1)
	
	await get_tree().create_timer(2.0).timeout
	
	esta_invulnerable = false
	$sonic_animations.modulate.a = 1.0

func die():
	var game_over_path = "res://scenes/ui/GameOver.tscn"
	if ResourceLoader.exists(game_over_path):
		get_tree().change_scene_to_file(game_over_path)
	else:
		get_tree().reload_current_scene()
