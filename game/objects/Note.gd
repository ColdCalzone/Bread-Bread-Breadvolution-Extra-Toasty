tool
extends Control

class_name Note

enum Direction {UP, RIGHT, DOWN, LEFT}

export(Direction) var direction = Direction.UP setget set_texture

var time : float = 0.0

func set_texture(value):
	direction = value
	$Sprite.region_rect.position.x = direction * 64
	self.visible = true
