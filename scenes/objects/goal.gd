extends Area2D

@export var next_level_path: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Sonic":
		complete_level()

func complete_level():
	# Mostrar pantalla de nivel completado
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
	else:
		# Volver al menú principal o mostrar "Juego Completado"
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
