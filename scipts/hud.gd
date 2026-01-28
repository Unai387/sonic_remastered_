extends CanvasLayer

@onready var ring_label = $RingLabel
@onready var time_label = $TimeLabel

var time_elapsed = 0.0

func _ready():
	GameManager.ring_count_changed.connect(update_rings)
	update_rings()

func _process(delta):
	time_elapsed += delta
	update_time()

func update_rings():
	ring_label.text = "Rings: %d" % GameManager.rings

func update_time():
	var total_seconds = int(time_elapsed)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
