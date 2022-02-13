extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()

func _process(delta):
	position += Vector2(20* rand_range(0.5, 1.2), 40 * -rand_range(0.5, 1.2)) * delta
	rotation += 0.5 * delta
