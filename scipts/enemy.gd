extends Area2D

@export var speed = 150.0
@export var move_distance = 300.0

var direction = 1
var start_position = Vector2.ZERO

func _ready():
	start_position = position
	body_entered.connect(_on_body_entered)

func _process(delta):
	position.x += speed * direction * delta
	
	if abs(position.x - start_position.x) > move_distance:
		direction *= -1
		$EnemysSprite.scale.x *= -1

func _on_body_entered(body):
	if body.name == "Sonic":
		if body.velocity.y > 0 and body.position.y < position.y - 10:
			body.velocity.y = -400
			destroy()
		else:
			body.hit()

func destroy():
	queue_free()
