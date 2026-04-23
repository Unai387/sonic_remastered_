extends CanvasLayer

# Usamos variables simples y las llenaremos en el _ready
var corazones = []

func _ready():
	# Buscamos los corazones dentro del Hud sin importar la ruta exacta
	var c1 = find_child("Corazon1", true, false)
	var c2 = find_child("Corazon2", true, false)
	var c3 = find_child("Corazon3", true, false)
	
	corazones = [c1, c2, c3]
	
	# Verificar si se encontraron para no dar error
	for c in corazones:
		if c == null:
			print("ERROR: No se encontró uno de los corazones en la escena")
	
	actualizar_interfaz_vidas(3)

func actualizar_interfaz_vidas(vidas_actuales: int):
	for i in range(corazones.size()):
		var corazon = corazones[i]
		if corazon == null: continue
		
		if i < vidas_actuales:
			# Vidas normales
			corazon.visible = true
			corazon.modulate = Color(1, 1, 1, 1) # Blanco/Normal
		elif vidas_actuales == 0 and i == 0:
			# EL ÚLTIMO GOLPE (Vidas en 0)
			# Hacemos que el primer corazón parpadee en rojo
			corazon.visible = true
			var tween = create_tween().set_loops() # Bucle infinito
			tween.tween_property(corazon, "modulate", Color(1, 0, 0, 1), 0.1) # Rojo
			tween.tween_property(corazon, "modulate", Color(1, 1, 1, 0.2), 0.1) # Transparente
		else:
			# Corazones ya perdidos
			corazon.visible = false
