extends CanvasLayer

onready var fps = $Label
onready var ifps = $Label2

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	fps.text = "FPS: " + String(Engine.get_frames_per_second())
	ifps.text = "Input FPS: " + String( round(1/ delta) )

func hide_fps():
	set_physics_process(false)
	fps.visible = false
	ifps.visible = false

func show_fps():
	set_physics_process(true)
	fps.visible = true
	ifps.visible = true
