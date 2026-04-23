extends Area2D

var path_follow = null
var sonic_ref = null
var en_loop = false

@export var boost_velocidad: float = 1.3

func _ready():
	var id = name.replace("TriggerLoop", "")
	path_follow = get_node_or_null("../CaminoLoop" + id + "/PathFollow2D")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Sonic" and not en_loop and path_follow != null:
		sonic_ref = body
		en_loop = true
		
		path_follow.progress_ratio = 0
		sonic_ref.global_position = path_follow.global_position
		sonic_ref.set_physics_process(false)
		
		var anim = sonic_ref.get_node_or_null("sonic_animations")
		if anim:
			anim.play("loop")

func _process(delta):
	if en_loop and sonic_ref:
		var v = abs(sonic_ref.speed) if "speed" in sonic_ref else 500.0
		path_follow.progress += max(v * boost_velocidad, 600.0) * delta
		sonic_ref.global_position = path_follow.global_position
		
		var anim_node = sonic_ref.get_node_or_null("sonic_animations")
		if anim_node:
			anim_node.rotation = path_follow.rotation
		
		if path_follow.progress_ratio >= 0.99:
			finalizar_loop()

func finalizar_loop():
	en_loop = false
	if sonic_ref:
		sonic_ref.set_physics_process(true)
		var anim = sonic_ref.get_node_or_null("sonic_animations")
		if anim:
			anim.rotation = 0
			# Quitamos el 'has_animation' que daba error
			anim.play("loop")
		sonic_ref = null
