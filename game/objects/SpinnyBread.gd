extends Control

const NORMAL = preload("res://sprites/bread.png")
const TOAST = preload("res://sprites/bread_toast.png")
const TOASTIER = preload("res://sprites/bread_toastier.png")
const BURNT = preload("res://sprites/bread_burnt.png")

onready var body = $RigidBody2D
onready var sprite = $RigidBody2D/Sprite
onready var tween = $Tween

var current_toast = 0

func _process(delta):
	body.rotation_degrees -= delta * 190 * (current_toast + 1)
	

func bunmp():
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.6, Vector2.ONE, 0.2, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func die():
	body.mode = RigidBody2D.MODE_RIGID
	body.apply_central_impulse(Vector2(rand_range(-70, -90), rand_range(-50, -60)))

func set_sprite(sprite_num : int):
	if sprite_num == current_toast: return
	current_toast = sprite_num
	match sprite_num:
		0:
			sprite.texture = NORMAL
		1:
			sprite.texture = TOAST
		2:
			sprite.texture = TOASTIER
		3:
			sprite.texture = BURNT
