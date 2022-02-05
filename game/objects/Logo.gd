extends HBoxContainer

const NORMAL_TITLE = Vector2(192, 52.5)
const EXPANDED_TITLE = Vector2(256, 70)

onready var extra_toasty = $VBoxContainer/HBoxContainer/TextureRect3
onready var bread = $TextureRect
onready var title = $VBoxContainer/TextureRect2

onready var tween = $Tween
onready var tween_scale = $TweenScale

func hide_extra():
	extra_toasty.visible = false
	title.rect_min_size = EXPANDED_TITLE
	title.rect_size = EXPANDED_TITLE

func show_extra():
	extra_toasty.visible = true
	title.rect_min_size = NORMAL_TITLE
	title.rect_size = NORMAL_TITLE

func rotate_to(degrees : float, dur : float):
	tween.interpolate_property(extra_toasty, "rect_rotation", extra_toasty.rect_rotation, degrees, dur, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()

func pulse(amount : float):
	tween_scale.stop_all()
	tween_scale.interpolate_property(extra_toasty, "rect_scale", extra_toasty.rect_scale, Vector2.ONE * amount, 0.2, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween_scale.interpolate_property(extra_toasty, "rect_scale", Vector2.ONE * amount, Vector2.ONE, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.2)
	tween_scale.start()
