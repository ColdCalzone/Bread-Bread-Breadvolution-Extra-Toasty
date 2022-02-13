tool
extends Note

class_name HoldNote

enum Part {END, MIDDLE, BEGIN}

export(Part) var part = Part.BEGIN setget set_texture

func set_texture(value):
	part = value
	$Sprite.region_rect.position.y = abs(part + (Settings.scroll - 1)) * 64 
	self.visible = true
