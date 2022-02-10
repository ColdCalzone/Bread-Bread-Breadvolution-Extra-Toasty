extends Control

onready var music_vol = $Options/SoundOptions/Music/MusicVol
onready var sfx_vol = $Options/SoundOptions/SFX/SFXVol
onready var fullscreen = $Options/Visual/Fullscreen/Fullscreen
onready var fps = $Options/Visual/FPS/ShowFPS
onready var latency = $Options/LatencyComp/Latency
onready var background = $Options/Visual/Backgrounds/Backgrounds
onready var back = $Back
onready var bg = $BackgroundScene/ParallaxBackground

func _ready():
	music_vol.value = Settings.music_volume
	sfx_vol.value = Settings.sound_volume
	fullscreen.pressed = Settings.fullscreen
	fps.pressed = Settings.show_fps
	latency.value = Settings.latency
	background.pressed = Settings.backgrounds
	

func _on_Back_pressed():
	TransitionManager.transition_to("title")

func _on_MusicVol_value_changed(value):
	Settings.set_music_volume(value)
	Settings.save_config()

func _on_SFXVol_value_changed(value):
	Settings.set_sound_volume(value)
	Settings.save_config()

func _on_Fullscreen_toggled(button_pressed):
	Settings.set_fullscreen(button_pressed)
	Settings.save_config()

func _on_ShowFPS_toggled(button_pressed):
	Settings.set_fps(button_pressed)
	Settings.save_config()

func _on_Latency_value_changed(value):
	Settings.latency = value
	Settings.save_config()

func _on_Backgrounds_toggled(button_pressed):
	Settings.set_background(button_pressed)
	Settings.save_config()
	bg.set_enabled(button_pressed)
