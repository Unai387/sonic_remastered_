extends Node2D

@export var swing_distance = 150.0  # Distancia de izq a der
@export var swing_speed = 1.0  # Velocidad del balanceo

var time = 0.0
var start_position = Vector2.ZERO

func _ready():
	start_position = $Platform.position
	print("Start position: ", start_position)  # Debug

func _process(delta):
	time += delta * swing_speed
	
	var offset_x = sin(time) * swing_distance
	
	# Usar global_position
	$Platform.global_position.x = start_position.x + offset_x
	$Platform.global_position.y = start_position.y
