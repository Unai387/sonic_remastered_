extends Control

func _ready():
	$VBoxContainer/Iniciar.pressed.connect(_on_start_pressed)
	$VBoxContainer/Salir.pressed.connect(_on_quit_pressed)
	$VBoxContainer/Niveles.pressed.connect(_on_levels_pressed)
func _on_start_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_levels_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
