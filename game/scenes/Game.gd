extends Control

onready var timer = $Label

var time : float = 0.0

var note_pointer : int = 0

var last_second : int = 0

export var speed : float = 200.0

export var bpm : float = 240

var pattern : Array = []

onready var keys = $CenterContainer/HBoxContainer.get_children()

onready var ms_accuracy = $MSAccuracy

func _ready():
	var path = SongData.get_level()
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var data = JSON.parse(file.get_as_text()).result
		if data is Dictionary:
			bpm = data.song_info.bpm
			speed = data.song_info.speed
			pattern = data.pattern
			print(data.song_info.song)
			MusicPlayer.set_music(data.song_info.song)
			# preprocessing for hold notes
			# 2 = begin 3 = end 4 = middle (can be ignored)
			for notes in range(pattern.size() - 1):
				print(notes, ", ", pattern[notes][1])
				for note in range(pattern[notes][0].size() - 1):
					if pattern[notes][0][note] == 2:
						var scan = 0
						while true:
							if pattern[notes + scan][0][note] == 3:
								pattern[notes][0][note] = [pattern[notes + scan][1]]
								break
							scan += 1
		else:
			get_tree().quit()
	for key in keys:
		key.speed = speed
	yield(get_tree().create_timer(2), "timeout")
	MusicPlayer.play()

func _physics_process(delta):
	time += delta
	timer.text = String(time)
	
	if note_pointer < pattern.size():
		if pattern[note_pointer][1] <= time + 2:
			for key in range(pattern[note_pointer][0].size()):
				if pattern[note_pointer][0][key] is Array:
					keys[key].spawn_hold(pattern[note_pointer][1] + 2, pattern[note_pointer][0][key][0] + 2)
				else:
					if pattern[note_pointer][0][key] == 1:
						keys[key].spawn_note(pattern[note_pointer][1] + 2)
			note_pointer += 1
			print("new note added")
	
	for note in get_tree().get_nodes_in_group("note"):
			note.rect_position.y = (time - note.time) * speed
			if (time / 60 * bpm) - (note.time / 60 * bpm) > 1:
				note.get_parent().remove_note(0)
	
	# Hold notes
	if Input.is_action_pressed("key_left") and keys[0].holding:
		if keys[0].notes.size() > 0:
			if keys[0].notes[0] is HoldNote:
				if keys[0].notes[0].time / 60 * bpm - (time / 60 * bpm) <= 0:
					# is this the end?
					if keys[0].notes[0].part == 0:
						keys[0].holding = false
					keys[0].remove_note(0)
	if Input.is_action_pressed("key_down") and keys[1].holding:
		if keys[0].notes.size() > 0:
			if keys[1].notes[0] is HoldNote:
				if keys[1].notes[0].time / 60 * bpm - (time / 60 * bpm) <= 0:
					# is this the end?
					if keys[1].notes[0].part == 0:
						keys[1].holding = false
					keys[1].remove_note(0)
	if Input.is_action_pressed("key_up") and keys[2].holding:
		if keys[0].notes.size() > 0:
			if keys[2].notes[0] is HoldNote:
				if keys[2].notes[0].time / 60 * bpm - (time / 60 * bpm) <= 0:
					# is this the end?
					if keys[2].notes[0].part == 0:
						keys[2].holding = false
					keys[2].remove_note(0)
	if Input.is_action_pressed("key_right") and keys[3].holding:
		if keys[0].notes.size() > 0:
			if keys[3].notes[0] is HoldNote:
				if keys[3].notes[0].time / 60 * bpm - (time / 60 * bpm) <= 0:
					# is this the end?
					if keys[3].notes[0].part == 0:
						keys[3].holding = false
					keys[3].remove_note(0)
	
	# regular notes
	if Input.is_action_just_pressed("key_left"):
		keys[0].press()
		if keys[0].notes.size() > 0:
			if (keys[0].notes[0].time / 60 * bpm) - (time / 60 * bpm) <= 1:
				if keys[0].notes[0] is HoldNote:
					# is it the beginning?
					if keys[0].notes[0].part == 2:
						keys[0].holding = true
						ms_accuracy.text= String(stepify(keys[0].notes[0].time - time, 0.0001) * 1000) + "MS"
						keys[0].remove_note(0)
				else:
					ms_accuracy.text= String(stepify(keys[0].notes[0].time - time, 0.0001) * 1000) + "MS"
					keys[0].remove_note(0)
	elif Input.is_action_just_released("key_left"):
		keys[0].release()
		keys[0].holding = false
	if Input.is_action_just_pressed("key_down"):
		keys[1].press()
		if keys[1].notes.size() > 0:
			if (keys[1].notes[0].time / 60 * bpm) - (time / 60 * bpm) < 1:
				if keys[1].notes[0] is HoldNote:
					# is it the beginning?
					if keys[1].notes[0].part == 2:
						keys[1].holding = true
						ms_accuracy.text= String(stepify(keys[1].notes[0].time - time, 0.0001) * 1000) + "MS"
						keys[1].remove_note(0)
				else:
					ms_accuracy.text= String(stepify(keys[1].notes[0].time - time, 0.0001) * 1000) + "MS"
					keys[1].remove_note(0)
	elif Input.is_action_just_released("key_down"):
		keys[1].release()
		keys[1].holding = false
	if Input.is_action_just_pressed("key_up"):
		keys[2].press()
		if keys[2].notes.size() > 0:
			if (keys[2].notes[0].time / 60 * bpm) - (time / 60 * bpm) <= 1:
				if keys[2].notes[0] is HoldNote:
					# is it the beginning?
					if keys[2].notes[0].part == 2:
						keys[2].holding = true
						ms_accuracy.text= String(stepify(keys[2].notes[0].time - time, 0.0001) * 1000) + "MS"
						keys[2].remove_note(0)
				else:
					ms_accuracy.text= String(stepify(keys[2].notes[0].time - time, 0.0001) * 1000) + "MS"
					keys[2].remove_note(0)
	elif Input.is_action_just_released("key_up"):
		keys[2].release()
		keys[2].holding = false
	if Input.is_action_just_pressed("key_right"):
		keys[3].press()
		if keys[3].notes.size() > 0:
			if (keys[3].notes[0].time / 60 * bpm) - (time / 60 * bpm) <= 1:
				if keys[3].notes[0] is HoldNote:
					# is it the beginning?
					if keys[3].notes[0].part == 2:
						keys[3].holding = true
						ms_accuracy.text= String(stepify(keys[3].notes[0].time - time, 0.0001) * 1000) + "MS"
						keys[3].remove_note(0)
				else:
					ms_accuracy.text= String(stepify(keys[3].notes[0].time - time, 0.0001) * 1000) + "MS"
					keys[3].remove_note(0)
	elif Input.is_action_just_released("key_right"):
		keys[3].release()
		keys[3].holding = false
