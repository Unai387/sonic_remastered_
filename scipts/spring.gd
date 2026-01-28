extends Area2D

@export var bounce_force = -700.0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D:
		body.velocity.y = bounce_force
		# Aquí podrías añadir una animación del resorte
