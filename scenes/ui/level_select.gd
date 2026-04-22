extends Control

func _ready():
	$ButtonContainer/Level1Button.pressed.connect(_on_level1_pressed)
	$ButtonContainer/Level2Button.pressed.connect(_on_level2_pressed)
	$ButtonContainer/Level3Button.pressed.connect(_on_level3_pressed)
	$ButtonContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_level1_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_level2_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")

func _on_level3_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
