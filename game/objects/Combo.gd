extends Label

onready var tween = $Tween

func set_combo(num : int):
	self.text = String(num)
	self.visible = num > 0
