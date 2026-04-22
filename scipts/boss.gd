extends CharacterBody2D

@export var health = 5
@export var move_speed = 100.0
@export var stun_duration = 1.5

var is_stunned = false
var is_defeated = false
var is_appearing = true
var direction = 1
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position
	
	$HeadHitbox.body_entered.connect(_on_head_hit)
	$DamageArea.body_entered.connect(_on_damage_player)
	
	# Animación de aparición
	if $AnimatedSprite.sprite_frames != null:
		$AnimatedSprite.play("appear")
		await $AnimatedSprite.animation_finished
	else:
		await get_tree().create_timer(1.0).timeout
	
	is_appearing = false
	if $AnimatedSprite.sprite_frames != null:
		$AnimatedSprite.play("idle")

func _physics_process(delta):
	if is_appearing or is_stunned or is_defeated:
		velocity.x = 0
	else:
		# Movimiento de patrulla
		velocity.x = direction * move_speed
		
		# Cambiar dirección al alejarse mucho del punto inicial
		if abs(global_position.x - start_position.x) > 200:
			direction *= -1
				
	# Gravedad
	if not is_on_floor():
		velocity.y += 980 * delta
	
	move_and_slide()

func _on_head_hit(body):
	if body.name == "Sonic" and not is_stunned and not is_defeated and not is_appearing:
		if body.velocity.y > 0:  # Sonic está cayendo
			take_damage()
			# Hacer rebotar a Sonic
			body.velocity.y = -400

func take_damage():
	health -= 1
	print("Boss golpeado! Vida restante: ", health)
	
	if health <= 0:
		defeat()
	else:
		stun()

func stun():
	is_stunned = true
	if $AnimatedSprite.sprite_frames != null:
		$AnimatedSprite.play("stunned")
	
	await get_tree().create_timer(stun_duration).timeout
	
	is_stunned = false
	if $AnimatedSprite.sprite_frames != null and not is_defeated:
		$AnimatedSprite.play("idle")

func defeat():
	is_defeated = true
	velocity.x = 0
	
	if $AnimatedSprite.sprite_frames != null:
		$AnimatedSprite.play("defeated")
		await $AnimatedSprite.animation_finished
	else:
		await get_tree().create_timer(2.0).timeout
	
	print("¡Boss derrotado!")
	
	# Desaparecer
	queue_free()
	
	# Mostrar victoria o siguiente nivel
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_damage_player(body):
	if body.name == "Sonic" and not is_defeated:
		body.hit()
