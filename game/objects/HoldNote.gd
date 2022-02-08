tool
extends Control

class_name HoldNote

enum Part {END, MIDDLE, BEGIN}

export(Part) var part = Part.BEGIN setget set_texture

var time : float = 0.0

func set_texture(value):
	part = value
	$Sprite.region_rect.position.y = part * 64
	self.visible = true
