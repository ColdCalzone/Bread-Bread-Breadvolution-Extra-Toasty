extends Control

onready var chart = $ChartBox/ChartCenter/Chart
onready var chart_parent = $ChartBox/ChartCenter
onready var bar_selector = $ChartBox/VBoxContainer/BarNum

onready var song_button = $VBoxContainer/Song/Button
onready var song_name = $VBoxContainer/Name/Text
onready var artist = $VBoxContainer/Artist/Text
onready var BPM = $VBoxContainer/BPM/BPM
onready var speed = $VBoxContainer/Speed/Speed
onready var file_dialog = $FileDialog

onready var music_button = $Audio/Button
onready var music_progress = $Audio/HSlider

onready var chart_button = Panel.new()

onready var chart_buttons = [
	preload("res://sprites/bread_left.png"), 
	preload("res://sprites/bread_down.png"), 
	preload("res://sprites/bread_up.png"), 
	preload("res://sprites/bread_right.png"), 
]

onready var chart_style = preload("res://src/chart_checkerboard.tres")

var loading_chart : bool = false

var edit_slider : bool = false
# value stored for music progress editing
var stored_val : float = 0.0

# audio stream - used for werid math stuff and also other things!!!!
var audio = load("res://sfx/bloop.ogg")
# I experimented with being able to add more than 4 coloums / keys. that didn't work. it crashed the
#game. The scene never even got added to the tree. I don't know why. I don't want to know why. 

# On a similar-ish note, I'm locking the editor to 4/4. I'll leave support for other signatures to
#another poor soul.

func add_rows():
	chart_parent.remove_child(chart)
	chart = GridContainer.new()
	chart.set("custom_constants/vseparation", 0)
	chart.set("custom_constants/hseparation", 0)
	chart_parent.add_child(chart)
	chart.columns = 4
	chart_button.rect_min_size = Vector2(22, 22)
	for i in range(16):
		for button in range(4):
			var new_button = chart_button.duplicate()
			var button_texture = TextureButton.new()
			button_texture.toggle_mode = true
			button_texture.rect_size = Vector2(22, 22)
			button_texture.texture_pressed = chart_buttons[button]
			button_texture.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			button_texture.expand = true
			new_button.add_child(button_texture)
			if (i + button) % 2 == 0:
				new_button.set("custom_styles/panel", chart_style)
			chart.add_child(new_button)

func _ready():
	add_rows()
	MusicPlayer.set_music(audio)

func _process(delta):
	if MusicPlayer.playing:
		if !edit_slider:
			music_progress.value = MusicPlayer.get_playback_position() / audio.get_length()

func _on_SongFile_pressed():
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.add_filter("*.ogg ; OGG Vorbis audio file")
	file_dialog.add_filter("*.wav ; WAV audio file")
	file_dialog.popup()


func _on_FileDialog_file_selected(path : String):
	file_dialog.clear_filters()
	if file_dialog.mode == FileDialog.MODE_OPEN_FILE:
		if loading_chart:
			pass
		else:
			song_button.text = path.rsplit("/", false, 1)[1]
			audio = load(path)
			MusicPlayer.set_music(audio)


func _on_MusicPlay_pressed():
	if !MusicPlayer.playing:
		MusicPlayer.play()
		music_button.icon = load("res://sprites/Pause.png")
	else:
		MusicPlayer.stop()
		music_button.icon = load("res://sprites/Play.png")


func _on_HSlider_gui_input(event : InputEvent):
	if event.is_action_pressed("left_mouse"):
		stored_val = MusicPlayer.get_playback_position()
		edit_slider = true
	elif event.is_action_released("left_mouse"):
		MusicPlayer.seek(stored_val * audio.get_length())
		edit_slider = false

func _on_HSlider_value_changed(value : float):
	if edit_slider:
		stored_val = value
