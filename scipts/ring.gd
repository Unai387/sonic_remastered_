extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Sonic":
		body.collect_ring()
		queue_free()  # Destruir el anillo
