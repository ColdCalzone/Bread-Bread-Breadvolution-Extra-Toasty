extends Label

onready var tween = $Tween

func set_combo(num : int):
	self.text = String(num)
	if num == 0:
		self.modulate.a = 0
		return
	self.modulate.a = 1
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 0.5, Vector2.ONE * 0.7, 0.2, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 0.9, Vector2.ONE * 0.5, 0.2, Tween.TRANS_QUART, Tween.EASE_OUT, 0.2)
	tween.start()
