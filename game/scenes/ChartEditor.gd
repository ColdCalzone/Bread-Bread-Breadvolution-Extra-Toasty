extends Control

onready var chart = $ChartBox/ChartCenter/Chart
onready var chart_parent = $ChartBox/ChartCenter
onready var bar_selector = $ChartBox/VBoxContainer/BarNum

onready var song_button = $VBoxContainer/Song/Button
onready var song_name = $VBoxContainer/Name/Text
onready var artist = $VBoxContainer/Artist/Text
onready var bpm = $VBoxContainer/BPM/BPM
onready var speed = $VBoxContainer/Speed/Speed
onready var file_dialog = $FileDialog
onready var measures_amount = $Label

onready var music_button = $Audio/Button
onready var music_progress = $Audio/HSlider

onready var default_icon_button = $VBoxContainer/Default
onready var clicked_icon_button = $VBoxContainer/Clicked

var default_icon : Image = Image.new()
var clicked_icon : Image = Image.new()

var default_icon_path : String = ""
var clicked_icon_path : String = ""

onready var chart_button = ChartButton.new()

onready var music_button_icons = [
	preload("res://sprites/Play.png"),
	preload("res://sprites/Pause.png")
]

onready var chart_buttons = [
	preload("res://sprites/bread_left.png") as StreamTexture, 
	preload("res://sprites/bread_down.png") as StreamTexture, 
	preload("res://sprites/bread_up.png") as StreamTexture, 
	preload("res://sprites/bread_right.png") as StreamTexture, 
]

onready var hold_buttons = [
	preload("res://sprites/baguette_start.png") as StreamTexture,
	preload("res://sprites/baguette.png") as StreamTexture,
	preload("res://sprites/baguette_end.png") as StreamTexture,
]

onready var chart_style = preload("res://src/chart_checkerboard.tres")

onready var chart_grid : Array = []

enum LoadingMode { CHART, SONG, DEFAULT_ICON, CLICK_ICON }

var loading_mode = LoadingMode.SONG

var edit_slider : bool = false
# value stored for music progress editing
var stored_val : float = 0.0

# value used for auto-switching bars, no other purpose
var last_bar : int = 0

# audio stream - used for werid math stuff and also other things!!!!
var audio = load("res://sfx/bloop.ogg")

# initialized with one value, fills to 16 in add_rows
var notes = [[
	[0,0,0,0]
]]

# 16th notes
var current_note = 0

var bpm_value : float = 60.0
var current_bar = 1

var delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

var song_path : String = ""
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
			new_button.current_direction = button
			new_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			new_button.connect("pressed", self, "change_note", [i * 4 + button])
			if (i + button) % 2 == 0:
				new_button.set("custom_styles/panel", chart_style)
			chart.add_child(new_button)
			new_button.normal_note = chart_buttons[button]
	chart_grid = chart.get_children()
	for _i in range(15):
		notes[current_bar - 1].append(notes[current_bar - 1][0].duplicate())

func _ready():
	add_rows()
	MusicPlayer.set_music(audio)
	
# warning-ignore:return_value_discarded
	MusicPlayer.connect("finished", self, "reset_audio_player")

func _process(_delta):
	if MusicPlayer.playing:
		if !edit_slider:
			music_progress.value = MusicPlayer.get_playback_position() / audio.get_length()
		current_note = (MusicPlayer.get_playback_position() / 60 * bpm_value * 4) + delay # BPM -> BPS -> 16th notes
		for i in range(chart_grid.size()):
			chart_grid[i].modulate = Color.white
		for i in range(4):
			chart_grid[int(current_note) % 16 * 4 + i].modulate = Color.red
		if int((current_note) / 16) > last_bar:
			last_bar = int((current_note) / 16)
			bar_selector.value = last_bar + 1

func change_note(mode : int, index : int):
# warning-ignore:integer_division
	var old_mode = notes[current_bar - 1][floor(index / 4)][index % 4]
	chart_grid[index].set_mode(mode)
# warning-ignore:integer_division
	notes[current_bar - 1][floor(index / 4)][index % 4] = mode * int(chart_grid[index].pressed)
	if old_mode == 2: 
		var holds = []
		var success = false
		for i in range(index, (notes[current_bar - 1].size() * 4) - 1, 4):
# warning-ignore:integer_division
# warning-ignore:integer_division
			if (notes[current_bar - 1][floor(i / 4)][i % 4] != 2 and notes[current_bar - 1][floor(i / 4)][i % 4] != 3) or index == i:
				holds.append(i)
			else:
# warning-ignore:integer_division
				success = notes[current_bar - 1][floor(i / 4)][i % 4] != 2
				break
		if success:
			for note in holds:
				change_note(0, note)
	if old_mode == 3:
		var holds = []
		var success = false
		for i in range(index, -1, -4):
# warning-ignore:integer_division
# warning-ignore:integer_division
			if (notes[current_bar - 1][floor(i / 4)][i % 4] != 2 and notes[current_bar - 1][floor(i / 4)][i % 4] != 3) or index == i:
				holds.append(i)
			else:
# warning-ignore:integer_division
				success = notes[current_bar - 1][floor(i / 4)][i % 4] != 3
				break
		if success:
			for note in holds:
				change_note(0, note)
	if mode == 2:
		var holds = []
		var success = false
		for i in range(index, (notes[current_bar - 1].size() * 4) - 1, 4):
			if index == i: continue
# warning-ignore:integer_division
			match notes[current_bar - 1][floor(i / 4)][i % 4]:
				0, 1:
					holds.append(i)
				2:
					break
				3:
					success = true
					break
		if success:
			for note in holds:
				change_note(4, note)
	if mode == 3:
		var holds = []
		var success = false
		for i in range(index, -1, -4):
			if index == i: continue
# warning-ignore:integer_division
			match notes[current_bar - 1][floor(i / 4)][i % 4]:
				0, 1:
					holds.append(i)
				2:
					success = true
					break
				3:
					break
		if success:
			for note in holds:
				change_note(4, note)
	

func reset_audio_player():
	music_button.pressed = false
	music_button.icon = music_button_icons[0]

func _on_SongFile_pressed():
	loading_mode = LoadingMode.SONG
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.add_filter("*.ogg ; OGG Vorbis audio file")
	file_dialog.add_filter("*.wav ; WAV audio file")
	file_dialog.popup()

func _on_FileDialog_file_selected(path : String):
	file_dialog.clear_filters()
	if file_dialog.mode == FileDialog.MODE_OPEN_FILE:
		# Loading a bread file
		match loading_mode:
			LoadingMode.CHART:
				var file = File.new()
				if !file.open(path, File.READ):
					var data = JSON.parse(file.get_as_text()).result
					if data is Dictionary:
						song_name.text = data.song_info.name
						artist.text = data.song_info.artist
						song_path = data.song_info.song
						song_button.text = song_path.rsplit("/", false, 1)[1]
						bpm_value = data.song_info.bpm
						speed.value = data.song_info.speed
						audio = load(song_path)
						MusicPlayer.set_music(audio)
						bpm.value = data.song_info.bpm
						
						if data.song_info.has("icons"):
							#LoadingMode.DEFAULT_ICON:
							default_icon_path = data.song_info.icons[0]
# warning-ignore:return_value_discarded
							default_icon.load(default_icon_path)
							var texture = ImageTexture.new()
							texture.create_from_image(default_icon)
							default_icon_button.icon = texture
							#LoadingMode.CLICK_ICON:
							clicked_icon_path = data.song_info.icons[1]
# warning-ignore:return_value_discarded
							clicked_icon.load(clicked_icon_path)
							texture = ImageTexture.new()
							texture.create_from_image(clicked_icon)
							clicked_icon_button.icon = texture
						
						var pattern = data.pattern
						var formatted_pattern = []
						var bar = []
						for note in pattern:
							# CAN I PLEASE GET YOUR ATTENTION
							# TODO: LOOK AT THIS. THIS IS WORKING JUST LOOK AT IT
							# look at me
							# Look at me.
							# I am grabbing you rn. cupping your face.
							# hi
							# look at this shit
							# I spent like an hour figuring out why after loading a file
							# hold notes wouldn't place until i removed one end of it
							# well guess what
							# this is the fix
							# you know how Javascript and by extension JSON have no int vs float
							# just "number"
							# well when going from JSON to GDScript it casts to float
							# makes sense
							# but when you have a match case for 0
							# 0.0 doesn't equal 0 stupid
							# but it still prints as 0
							# so you'd never fuckin know
							# unless you thought of this
							# I literally thought "this better not fucking work" before writing it
							# look at that
							# it worked
							var local_notes = []
							for number in note[0]:
								local_notes.append(int(number))
							bar.append(local_notes.duplicate())
							if bar.size() == 16:
								formatted_pattern.append(bar.duplicate(true))
								bar = []
						notes = formatted_pattern.duplicate(true)
						# Hacky. i do not care !
						bar_selector.value = 1
						current_bar = 1
						_on_BarNum_value_changed(1)
				file.close()
			# Loading a song
			LoadingMode.SONG:
				song_button.text = path.rsplit("/", false, 1)[1]
				song_path = path
				audio = load(path)
				MusicPlayer.set_music(audio)
			LoadingMode.DEFAULT_ICON:
				default_icon_path = path
# warning-ignore:return_value_discarded
				default_icon.load(path)
				var texture = ImageTexture.new()
				texture.create_from_image(default_icon)
				default_icon_button.icon = texture
			LoadingMode.CLICK_ICON:
				clicked_icon_path = path
# warning-ignore:return_value_discarded
				clicked_icon.load(path)
				var texture = ImageTexture.new()
				texture.create_from_image(clicked_icon)
				clicked_icon_button.icon = texture
	# Saving a bread file
	else:
		var file = File.new()
		if !file.open(path, File.WRITE):
			var pattern = []
			var consecutive_empty_bars : int = 0
			for bar in notes.size():
				var consecutive_empty_notes : int = 0
				for note in notes[bar].size():
					if notes[bar][note] == [0, 0, 0, 0]:
						consecutive_empty_notes += 1
					pattern.append([notes[bar][note], (bar * 4 + note) * 60 / bpm_value / 4])
				if consecutive_empty_notes == 16:
					consecutive_empty_bars += 1
				else:
					consecutive_empty_bars = 0
			for _i in range(consecutive_empty_bars * 16):
				pattern.pop_back()
			var data = {
				"song_info": {
					"name" : song_name.text,
					"artist" : artist.text,
					"song" : song_path,
					"bpm" : bpm_value,
					"speed" : speed.value,
					"icons" : [default_icon_path, clicked_icon_path]
				},
				"pattern" : pattern
			}
			file.store_string(JSON.print(data))
			file.close()


func _on_MusicPlay_pressed():
	if !MusicPlayer.playing:
		MusicPlayer.play()
		MusicPlayer.seek((current_bar - 1) / bpm_value * 60 * 4)
		music_button.icon = music_button_icons[1]
		delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	else:
		MusicPlayer.stop()
		last_bar = 0
		for button in chart_grid:
			button.modulate = Color.white
		music_button.icon = music_button_icons[0]


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

func _on_Speed_value_changed(value : float):
	MusicPlayer.pitch_scale = value

func _on_Save_pressed():
	file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
	file_dialog.add_filter("*.bread ; BBB Chart File")
	file_dialog.popup()

func _on_Load_pressed():
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.add_filter("*.bread ; BBB Chart File")
	loading_mode = LoadingMode.CHART
	file_dialog.popup()


func _on_OutputChart_pressed():
	print("\n")
	for bar in notes:
		for note in bar:
			print(note)
		print("------------")


func _on_BarNum_value_changed(value):
	current_bar = value
	for button in chart_grid:
			button.modulate = Color.white
	if current_bar > notes.size():
		var blank = [0,0,0,0]
		var bar = []
		for _i in range(16):
			bar.append(blank.duplicate())
		while current_bar > notes.size():
			notes.append(bar.duplicate(true))
	for button in chart_grid.size():
		chart_grid[button].pressed = false
		chart_grid[button].set_mode(notes[current_bar - 1][button / 4][button % 4])


func _on_BPM_value_changed(value):
	bpm_value = value
	measures_amount.text = "Number of measures: " + String(ceil(audio.get_length() / 60 * bpm_value / 4))


func _on_DefaultIcon_pressed():
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.add_filter("*.png ; PNG Images")
	loading_mode = LoadingMode.DEFAULT_ICON
	file_dialog.popup()


func _on_ClickedIcon_pressed():
	file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	file_dialog.add_filter("*.png ; PNG Images")
	loading_mode = LoadingMode.CLICK_ICON
	file_dialog.popup()
