extends Control

onready var music_vol = $Options/SoundOptions/Music/MusicVol
onready var sfx_vol = $Options/SoundOptions/SFX/SFXVol
onready var fullscreen = $Options/Visual/Fullscreen/Fullscreen
onready var fps = $Options/Visual/FPS/ShowFPS
onready var latency = $Options/LatencyComp/Latency
onready var background = $Options/Visual/Backgrounds/Backgrounds
onready var scroll = $Options/Scroll/Scroll
onready var effects = $Options/Visual/Effects/Effects
onready var back = $Back
onready var bg = $BackgroundScene/ParallaxBackground

onready var left_button = $VBoxContainer/Buttons/Left
onready var down_button = $VBoxContainer/Buttons/Down
onready var up_button = $VBoxContainer/Buttons/Up
onready var right_button = $VBoxContainer/Buttons/Right

var editing_button = null

func _ready():
	scroll.add_item("Downscroll")
	scroll.add_item("Upscroll")
	scroll.selected = -(Settings.scroll - 1 / 2)
	music_vol.value = Settings.music_volume
	sfx_vol.value = Settings.sound_volume
	fullscreen.pressed = Settings.fullscreen
	fps.pressed = Settings.show_fps
	latency.value = Settings.latency
	background.pressed = Settings.backgrounds
	effects.pressed = Settings.effects
	left_button.text = OS.get_scancode_string(Settings.key_binds[0])
	down_button.text = OS.get_scancode_string(Settings.key_binds[1])
	up_button.text = OS.get_scancode_string(Settings.key_binds[2])
	right_button.text = OS.get_scancode_string(Settings.key_binds[3])
	

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


func _on_Scroll_item_selected(index):
	Settings.scroll = -(index * 2 - 1)
	Settings.save_config()


func _on_Effects_toggled(button_pressed):
	Settings.effects = button_pressed
	Settings.save_config()


func _on_Left_pressed():
	editing_button = left_button


func _on_Down_pressed():
	editing_button = down_button


func _on_Up_pressed():
	editing_button = up_button


func _on_Right_pressed():
	editing_button = right_button

func _input(event):
	if editing_button != null:
		if event is InputEventKey:
			editing_button.text = OS.get_scancode_string(event.scancode) 
			match editing_button:
				left_button:
					Settings.key_binds[0] = event.scancode
					InputMap.action_erase_events("key_left")
					InputMap.action_add_event("key_left", event)
				down_button:
					Settings.key_binds[1] = event.scancode
					InputMap.action_erase_events("key_down")
					InputMap.action_add_event("key_down", event)
				up_button:
					Settings.key_binds[2] = event.scancode
					InputMap.action_erase_events("key_up")
					InputMap.action_add_event("key_up", event)
				right_button:
					Settings.key_binds[3] = event.scancode
					InputMap.action_erase_events("key_right")
					InputMap.action_add_event("key_right", event)
			editing_button = null
