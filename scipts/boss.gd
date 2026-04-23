extends CharacterBody2D

@export var health = 5
@export var move_speed = 130.0
@export var attack_speed = 450.0
@export var follow_range = 600.0

var player = null
var is_stunned = false
var is_defeated = false
var is_attacking = false

@onready var sprite = $AnimatedSprite

func _ready():
	player = get_tree().current_scene.find_child("Sonic", true, false)
	$HeadHitbox.body_entered.connect(_on_head_hit)
	$DamageArea.body_entered.connect(_on_damage_player)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 980 * delta
		
	if is_defeated or is_stunned:
		velocity.x = move_toward(velocity.x, 0, 10)
	elif not is_attacking:
		ia_persecucion()

	move_and_slide()

func ia_persecucion():
	if player:
		var dist = player.global_position.x - global_position.x
		if abs(dist) < follow_range:
			sprite.flip_h = dist > 0
			if abs(dist) < 180:
				atacar()
			else:
				velocity.x = sign(dist) * move_speed
				sprite.play("idle")
		else:
			velocity.x = 0

func atacar():
	if is_attacking: return
	is_attacking = true
	velocity.x = 0
	await get_tree().create_timer(0.4).timeout
	
	if not is_defeated and not is_stunned:
		var dir = 1 if sprite.flip_h else -1
		velocity.x = dir * attack_speed
		await get_tree().create_timer(0.8).timeout
	
	is_attacking = false

func _on_head_hit(body):
	if body.name == "Sonic" and not is_stunned and not is_defeated:
		if body.velocity.y > 0:
			take_damage()
			body.velocity.y = -400

func take_damage():
	health -= 1
	is_stunned = true
	sprite.play("stunned")
	await get_tree().create_timer(1.0).timeout
	is_stunned = false
	if health <= 0: defeat()

func defeat():
	is_defeated = true
	sprite.play("defeated")
	await get_tree().create_timer(4.0).timeout
	$BodyCollision.set_deferred("disabled", true)
	queue_free()

func _on_damage_player(body):
	if body.name == "Sonic" and not is_defeated and not is_stunned:
		if body.has_method("recibir_dano"):
			body.recibir_dano()
