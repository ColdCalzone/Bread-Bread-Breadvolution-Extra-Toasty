extends Control

onready var music_vol = $Options/SoundOptions/Music/HSlider
onready var sfx_vol = $Options/SoundOptions/SFX/HSlider
onready var fullscreen = $Options/Visual/Fullscreen/CheckButton
onready var fps = $Options/Visual/FPS/CheckButton
onready var latency = $Options/LatencyComp/SpinBox
onready var back = $Back

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Back_pressed():
	TransitionManager.transition_to("title")
