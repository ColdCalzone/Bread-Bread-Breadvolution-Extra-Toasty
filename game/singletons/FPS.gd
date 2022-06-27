extends CanvasLayer

onready var fps = $Label

func _process(delta):
	fps.text = "FPS: " + String(round(1 / delta))

func hide_fps():
	set_process(false)
	fps.visible = false

func show_fps():
	set_process(true)
	fps.visible = true
