tool
extends Control

class_name Note

enum Direction {UP, RIGHT, DOWN, LEFT}

export(Direction) var direction = Direction.UP setget set_texture

onready var parent = get_parent()

onready var timer = $Timer

var time : float = 0.0

var perished : bool = false

func set_texture(value):
	direction = value
	$Sprite.region_rect.position.x = direction * 64
	self.visible = true

func remove_self():
	perished = true
	# slightly hacky, could go wrong
	# TODO if anything goes wrong, fix this.
	parent.remove_note(0, true)
	timer.start()
	yield(timer, "timeout")
	queue_free()
