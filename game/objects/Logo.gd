extends HBoxContainer

const NORMAL_TITLE = Vector2(192, 52.5)
const EXPANDED_TITLE = Vector2(256, 70)

onready var extra_toasty = $VBoxContainer/HBoxContainer/TextureRect3
onready var bread = $BreadSpin/TextureRect
onready var bread_spin = $BreadSpin
onready var title = $VBoxContainer/TextureRect2

onready var tween = $Tween
onready var tween_scale = $TweenScale
onready var tween_bounce = $TweenBounce
onready var tween_spin = $TweenBreadRotate
onready var audio = $Click

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

func _on_BigBread_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index < 3:
			tween_bounce.stop_all()
			if bread.rect_scale.x == bread.rect_scale.y:
				audio.pitch_scale = 1/bread.rect_scale.y
			if randi() % 30 == 0:
				tween_spin.reset_all()
				tween_spin.interpolate_property(bread_spin, "rect_scale", Vector2.ONE, Vector2.LEFT + Vector2.DOWN, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
				tween_spin.interpolate_property(bread_spin, "rect_scale", Vector2.LEFT + Vector2.DOWN, Vector2.ONE, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT, 0.3)
				tween_spin.start()
			audio.play()
			tween_bounce.interpolate_property(bread, "rect_scale", bread.rect_scale, bread.rect_scale * 0.79, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween_bounce.interpolate_property(bread, "rect_scale", bread.rect_scale * 0.79, Vector2.ONE, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.1)
			tween_bounce.start()
