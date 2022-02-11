extends CanvasLayer

onready var fps = $Label
onready var ifps = $Label2

func _ready():
	ifps.text = "Input FPS: " + String(Engine.get_iterations_per_second())

func _process(delta):
	fps.text = "FPS: " + String(round(1 / delta))

func hide_fps():
	set_process(false)
	fps.visible = false
	ifps.visible = false

func show_fps():
	set_process(true)
	fps.visible = true
	ifps.visible = true
