extends CanvasLayer

# --- VARIABLES ORIGINALES ---
var corazones = []

# --- VARIABLES DE CONTADOR ---
@onready var RingLabel = find_child("RingLabel", true, false)
@onready var TimeLabel = find_child("TimeLabel", true, false)
var tiempo_total: float = 0.0

func _ready():
	# Buscamos los corazones dentro del Hud
	var c1 = find_child("Corazon1", true, false)
	var c2 = find_child("Corazon2", true, false)
	var c3 = find_child("Corazon3", true, false)
	
	corazones = [c1, c2, c3]
	
	# Verificar si se encontraron
	for c in corazones:
		if c == null:
			print("ERROR: No se encontró uno de los corazones")
	
	if RingLabel == null: print("ERROR: No se encontró RingLabel")
	if TimeLabel == null: print("ERROR: No se encontró TimeLabel")
	
	actualizar_interfaz_vidas(3)

func _process(delta):
	tiempo_total += delta
	actualizar_interfaz_tiempo()

# --- FUNCIONES DE ACTUALIZACIÓN ---

func actualizar_interfaz_anillos(cantidad: int):
	if RingLabel:
		# Añadimos "Rings: " antes del número
		RingLabel.text = "Rings: " + str(cantidad).pad_zeros(0)

func actualizar_interfaz_tiempo():
	if TimeLabel:
		var minutos = int(tiempo_total / 60)
		var segundos = int(tiempo_total) % 60
		TimeLabel.text = str(minutos) + ":" + str(segundos).pad_zeros(2)

func actualizar_interfaz_vidas(vidas_actuales: int):
	for i in range(corazones.size()):
		var corazon = corazones[i]
		if corazon == null: continue
		
		if i < vidas_actuales:
			corazon.visible = true
			corazon.modulate = Color(1, 1, 1, 1)
		elif vidas_actuales == 0 and i == 0:
			corazon.visible = true
			var tween = create_tween().set_loops()
			tween.tween_property(corazon, "modulate", Color(1, 0, 0, 1), 0.1)
			tween.tween_property(corazon, "modulate", Color(1, 1, 1, 0.2), 0.1)
		else:
			corazon.visible = false
