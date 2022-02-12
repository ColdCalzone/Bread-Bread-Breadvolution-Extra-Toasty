extends Control

var time : float = 0.0
var last_beat : int = 0

var note_pointer : int = 0

var last_second : int = 0

export var speed : float = 200.0

export var bpm : float = 240

var pattern : Array = []

onready var keys = $CenterContainer/HBoxContainer.get_children()

onready var ms_accuracy = $MSAccuracy

onready var combo_text = $ComboCenter/Combo

var combo : int = 0
var highest_combo : int = 0
var combo_breaks : int = 0
var total_notes : int = 0
var sweets : int = 0
var goods : int = 0
var oks : int = 0
var ehs : int = 0
var misses : int = 0

var score : float = 0.0
onready var score_text : Label = $Score

var multiplier : float = 1.0

onready var bg = $BackgroundScene/ParallaxBackground

onready var song_progress = $ProgressCenter/SongProgress

onready var popup = $PopupsCenter/ScoreIndicator

onready var multi_progress = $Multiplier/CenterContainer/TextureProgress

onready var blind = $Blind

onready var toast_meter = $Toast/CenterContainer/TextureProgress

onready var spinny_bread = $SpinnyBread

var toast = 1.0
var highest_toast = 1.0

onready var pause_menu = preload("res://objects/PauseMenu.tscn")

onready var results = preload("res://objects/ResultsScreen.tscn")

onready var _game_over = preload("res://objects/GameOver.tscn")

var timer = null

var scroll_direction = 0

var is_game_over : bool = false

var tween = Tween.new()

var actions = ["key_left", "key_down", "key_up", "key_right"]

# weird timing things!!!
# because of lag reasons using _physics_process to time the song doesn't work...
# but it runs more than process. So I'm using both to be generally better at timing

var phys_time : float = 0.0

func pause():
	var new_pause = pause_menu.instance()
	self.add_child(new_pause)
	#time = MusicPlayer.get_playback_position()
	new_pause.pause()

func _ready():
	blind.visible = SongData.blind
	multiplier += (int(SongData.no_miss) * 10) + (int(SongData.perfect) * 15) + (int(SongData.blind) * 5)
	if SongData.no_miss:
		toast = 10.0
	if SongData.perfect:
		toast = 20.0
	MusicPlayer.stop()
	song_progress.value = 0
	
	scroll_direction = Settings.scroll
	if scroll_direction == -1:
		$CenterContainer.rect_position.y = 40
	blind.rect_scale.y = scroll_direction
	
	var path = SongData.get_level()
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var data = JSON.parse(file.get_as_text()).result
		if data is Dictionary:
			bpm = data.song_info.bpm
			speed = data.song_info.speed
			pattern = data.pattern
			MusicPlayer.set_music(data.song_info.song)
			# preprocessing for hold notes
			# 2 = begin 3 = end 4 = middle (can be ignored)
			for notes in range(pattern.size()):
				for note in range(pattern[notes][0].size()):
					total_notes += int(pattern[notes][0][note] != 0.0 and pattern[notes][0][note] != 3.0 and pattern[notes][0][note] != 4.0)
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
	bg.speed = speed
	
	time -= AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	timer = Timer.new()
	timer.wait_time =  2 - float(Settings.latency) / 1000
	add_child(timer)
	timer.start()
	yield(timer, "timeout")
	MusicPlayer.connect("finished", self, "end_game")
	MusicPlayer.play()

func _process(delta):
	time += delta
	phys_time = 0
	song_progress.value = MusicPlayer.get_playback_position() / MusicPlayer.stream.get_length()

func _physics_process(delta):
	phys_time += delta
	var beat = (time + phys_time) / 60 * bpm
	if int(beat) > last_beat and Settings.effects:
		last_beat = int(beat)
		spinny_bread.bunmp()
	var accuracy = null
	var notes_hit = 0
	if note_pointer < pattern.size():
		if pattern[note_pointer][1] <= (time + phys_time) + 2:
			for key in range(pattern[note_pointer][0].size()):
				if pattern[note_pointer][0][key] is Array:
					keys[key].spawn_hold(pattern[note_pointer][1] + 2, pattern[note_pointer][0][key][0] + 2)
				else:
					if pattern[note_pointer][0][key] == 1:
						keys[key].spawn_note(pattern[note_pointer][1] + 2)
			note_pointer += 1
	
	for note in get_tree().get_nodes_in_group("note"):
			note.rect_position.y = ((time + phys_time) - note.time) * speed * scroll_direction
			if beat - (note.time / 60 * bpm) > 60 / bpm / 4:
				note.get_parent().remove_note(0)
				if (SongData.no_miss or SongData.perfect) and not SongData.unkillable:
					game_over()
				if combo > 0:
					combo_breaks += 1
				combo = 0
				if note is HoldNote:
					if note.part == 2:
						score -= 100 * multiplier * toast
						misses += 1
					else:
						score -= 10
				else:
					score -= 100 * multiplier * toast
					misses += 1
				multiplier = 1
				toast += 0.5
	
	if SongData.aim_bot:
		for key in range(keys.size()):
			if keys[key].notes.size() > 0:
				if keys[key].notes[0].time  <= time + (phys_time / 2):
					Input.action_press(actions[key])
				elif not keys[key].holding:
					Input.action_release(actions[key])
				
	
	# Hold notes
	if Input.is_action_pressed("key_left") and keys[0].holding:
		if keys[0].notes.size() > 0:
			if keys[0].notes[0] is HoldNote:
				if keys[0].notes[0].time / 60 * bpm - beat <= 0:
					# is this the end?
					if keys[0].notes[0].part == 0:
						keys[0].holding = false
					keys[0].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
					
	if Input.is_action_pressed("key_down") and keys[1].holding:
		if keys[0].notes.size() > 0:
			if keys[1].notes[0] is HoldNote:
				if keys[1].notes[0].time / 60 * bpm - beat <= 0:
					# is this the end?
					if keys[1].notes[0].part == 0:
						keys[1].holding = false
					keys[1].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
	
	if Input.is_action_pressed("key_up") and keys[2].holding:
		if keys[0].notes.size() > 0:
			if keys[2].notes[0] is HoldNote:
				if keys[2].notes[0].time / 60 * bpm - beat <= 0:
					# is this the end?
					if keys[2].notes[0].part == 0:
						keys[2].holding = false
					keys[2].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
	
	if Input.is_action_pressed("key_right") and keys[3].holding:
		if keys[0].notes.size() > 0:
			if keys[3].notes[0] is HoldNote:
				if keys[3].notes[0].time / 60 * bpm - beat <= 0:
					# is this the end?
					if keys[3].notes[0].part == 0:
						keys[3].holding = false
					keys[3].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
	
	# regular notes
	if Input.is_action_just_pressed("key_left"):
		keys[0].press()
		if keys[0].notes.size() > 0:
			if (keys[0].notes[0].time / 60 * bpm) - beat <= 60 / bpm / 2:
				if keys[0].notes[0] is HoldNote:
					# is it the beginning?
					if keys[0].notes[0].part == 2:
						keys[0].holding = true
						accuracy = keys[0].notes[0].time - (time + phys_time)
						keys[0].remove_note(0)
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[0].notes[0].time - (time + phys_time)
					keys[0].remove_note(0)
					combo += 1
					notes_hit += 1
			else:
				score -= 10 * toast * multiplier
				misses += 1
	elif Input.is_action_just_released("key_left"):
		keys[0].release()
		keys[0].holding = false
	if Input.is_action_just_pressed("key_down"):
		keys[1].press()
		if keys[1].notes.size() > 0:
			if (keys[1].notes[0].time / 60 * bpm) - beat < 60 / bpm / 2:
				if keys[1].notes[0] is HoldNote:
					# is it the beginning?
					if keys[1].notes[0].part == 2:
						keys[1].holding = true
						accuracy = keys[1].notes[0].time - (time + phys_time)
						keys[1].remove_note(0)
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[1].notes[0].time - (time + phys_time)
					keys[1].remove_note(0)
					combo += 1
					notes_hit += 1
			else:
				score -= 10 * toast * multiplier
				misses += 1
	elif Input.is_action_just_released("key_down"):
		keys[1].release()
		keys[1].holding = false
	if Input.is_action_just_pressed("key_up"):
		keys[2].press()
		if keys[2].notes.size() > 0:
			if (keys[2].notes[0].time / 60 * bpm) - beat <= 60 / bpm / 2:
				if keys[2].notes[0] is HoldNote:
					# is it the beginning?
					if keys[2].notes[0].part == 2:
						keys[2].holding = true
						accuracy = keys[2].notes[0].time - (time + phys_time)
						keys[2].remove_note(0)
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[2].notes[0].time - (time + phys_time)
					keys[2].remove_note(0)
					combo += 1
					notes_hit += 1
			else:
				score -= 10 * toast * multiplier
				misses += 1
	elif Input.is_action_just_released("key_up"):
		keys[2].release()
		keys[2].holding = false
	if Input.is_action_just_pressed("key_right"):
		keys[3].press()
		if keys[3].notes.size() > 0:
			if (keys[3].notes[0].time / 60 * bpm) - beat <= 60 / bpm / 2:
				if keys[3].notes[0] is HoldNote:
					# is it the beginning?
					if keys[3].notes[0].part == 2:
						keys[3].holding = true
						accuracy = keys[3].notes[0].time - (time + phys_time)
						keys[3].remove_note(0)
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[3].notes[0].time - (time + phys_time)
					keys[3].remove_note(0)
					combo += 1
					notes_hit += 1
			else:
				score -= 10 * toast * multiplier
				misses += 1
	elif Input.is_action_just_released("key_right"):
		keys[3].release()
		keys[3].holding = false
	
	if accuracy != null:
		ms_accuracy.text= String(stepify(accuracy, 0.0001) * 1000) + "MS"
		# God these values are bad
		# TODO make these make sense
		if abs(accuracy / 60 * bpm) < 60 / bpm / 8:
			popup.set_popup(0)
			sweets += notes_hit
			score += notes_hit * 300 * multiplier * toast
			multiplier += 0.5
		elif SongData.perfect:
			game_over()
		elif abs(accuracy / 60 * bpm) < 60 / bpm / 6:
			popup.set_popup(1)
			goods += notes_hit
			score += notes_hit * 150 * multiplier * toast
			multiplier += 0.1
		elif abs(accuracy / 60 * bpm) < 60 / bpm / 4:
			popup.set_popup(2)
			oks += notes_hit
			score += notes_hit * 50 * multiplier * toast
		else:
			popup.set_popup(3)
			ehs += notes_hit
			score += notes_hit * 10 * multiplier * toast
			if multiplier > 1:
				multiplier -= 0.1
	if misses > 0 and SongData.perfect:
		game_over()
	multi_progress.value = multiplier - 1
	toast_meter.value = (toast - 1)
	if toast > 20 and not SongData.unkillable:
		game_over()
	
	if combo > highest_combo:
		highest_combo = combo
	
	if toast > highest_toast:
		highest_toast = toast
	
	if combo > 0 and toast > 0:
		toast -= delta / 10
	
	score_text.text = "Score: " + String(int(score))
	
	if Input.is_action_just_pressed("pause"):
		pause()
	
	combo_text.set_combo(combo)

func end_game():
	set_physics_process(false)
	var new_results = results.instance()
	add_child(new_results)
	new_results.fade_in()

func _input(event : InputEvent):
	if event is InputEventKey and is_game_over:
		MusicPlayer.disconnect("finished", self, "end_game")
		if event.is_pressed() and not event.is_echo():
			tween.stop_all()
			timer.stop()
			MusicPlayer.stop()
			MusicPlayer.pitch_scale = 1
			var gameover = _game_over.instance()
			self.add_child(gameover)
			gameover.game_over()

func game_over():
	is_game_over = true
	MusicPlayer.disconnect("finished", self, "end_game")
	set_physics_process(false)
	set_process(false)
	if Settings.effects:
		spinny_bread.die()
		add_child(tween)
		tween.interpolate_property(MusicPlayer, "pitch_scale", 1, 0, 1.0)
		tween.start()
		yield(tween, "tween_all_completed")
		timer.wait_time *= 2
		timer.start()
		yield(timer, "timeout")
		MusicPlayer.stop()
		MusicPlayer.pitch_scale = 1
	var gameover = _game_over.instance()
	self.add_child(gameover)
	gameover.game_over()
