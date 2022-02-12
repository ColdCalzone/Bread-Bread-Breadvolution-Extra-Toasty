extends Control

onready var sprite = $RigidBody2D
onready var tween = $Tween

func _process(delta):
	sprite.rotation_degrees += delta * -360
	

func bunmp():
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.6, Vector2.ONE, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func die():
	sprite.mode = RigidBody2D.MODE_RIGID
	sprite.apply_central_impulse(Vector2(rand_range(-70, -90), rand_range(-50, -60)))
