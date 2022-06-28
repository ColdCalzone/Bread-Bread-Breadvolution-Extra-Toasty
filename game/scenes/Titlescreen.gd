extends Control

onready var logo = $CenterContainer/Logo
var spectrum 

const MIN_DB = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	DiscordManager.set_activity()
	MusicPlayer.set_music("res://Music/Just_Existing_v4.ogg", true, true)
	MusicPlayer.pitch_scale = 1.0
	spectrum = AudioServer.get_bus_effect_instance(1,0)
	while true:
		logo.rotate_to(-1.5, 1.5)
		yield(logo.tween, "tween_all_completed")
		logo.rotate_to(4.5, 1.5)
		yield(logo.tween, "tween_all_completed")

var has_pulsed = false

func _process(_delta):
	DiscordManager.discord.run_callbacks()
	# shamelessly stolen from the example in the docs - check "res://scenes/AudioAnalyzeTest.tscn"
	# 1380 - 2070 is the frequency range I decided on
	var magnitude: float = spectrum.get_magnitude_for_frequency_range(1380, 2070).length()
	var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
	if energy > 0.0:
		if !has_pulsed:
			logo.pulse(1 + energy)
			has_pulsed = true
	else:
		has_pulsed = false

# Buttons

func _on_Quit_pressed():
	get_tree().quit()


func _on_Settings_pressed():
	TransitionManager.transition_to("settings")


func _on_Play_pressed():
	TransitionManager.transition_to("play")


func _on_Credits_pressed():
	TransitionManager.transition_to("credits")
