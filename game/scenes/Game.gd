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
var base_toast = 1.0
var highest_toast = 1.0

onready var pause_menu = preload("res://objects/PauseMenu.tscn")

onready var results = preload("res://objects/ResultsScreen.tscn")

onready var _game_over = preload("res://objects/GameOver.tscn")

onready var timer = $Timer

var scroll_direction = 0

var is_game_over : bool = false

onready var tween = $Tween

onready var credits = [$Credits1, $Credits2]

onready var title = $Credits1/Title
onready var length = $Credits1/Time
onready var artist = $Credits2/Artist
onready var bpm_text = $Credits2/BPM

var actions = ["key_left", "key_down", "key_up", "key_right"]

# weird timing things!!!
# because of lag reasons using _physics_process to time the song doesn't work...
# but it runs more than process. So I'm using both to be generally better at timing

var phys_time : float = 0.0

# Stuff used for comparison, i.e half a beat for checking accuracy
var half_beat : float = 0.0
var quarter_beat : float = 0.0
var sixth_beat : float = 0.0
var eigth_beat : float = 0.0
var bps : float = 0.0
var inverse_bps : float = 0.0

var can_die = false

var delay = 0.0

func pause():
	
	var new_pause = pause_menu.instance()
	self.add_child(new_pause)
	#time = MusicPlayer.get_playback_position()
	new_pause.pause()

func _ready():
	set_process_input(false)
	MusicPlayer.stop()
	MusicPlayer.seek(0)
	blind.visible = SongData.blind
	multiplier += (int(SongData.no_miss) * 10) + (int(SongData.perfect) * 15) + (int(SongData.blind) * 5)
	if SongData.no_miss:
		base_toast += 10.0
	if SongData.perfect:
		base_toast += 15.0
	if SongData.blind:
		base_toast += 4.0
	toast = base_toast
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
			bpm_text.text = "BPM: " + String(bpm)
			artist.text = data.song_info.artist
			title.text = data.song_info.name
			speed = data.song_info.speed
			pattern = data.pattern
			MusicPlayer.set_music(data.song_info.song)
			var seconds = int(MusicPlayer.stream.get_length()) % 60
			length.text = "Length: " + String(int(MusicPlayer.stream.get_length() / 60)) + ":" + ("0" if seconds < 10 else "") + String(seconds)
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
	
	bps = bpm * 60.0
	inverse_bps = 60.0 / bpm
	half_beat = 60.0 / bpm / 2
	quarter_beat = 60.0 / bpm / 4
	sixth_beat = 60.0 / bpm / 6
	eigth_beat = 60.0 / bpm / 8
	
	for key in keys:
		key.speed = speed
	bg.speed = speed
	
	tween.interpolate_property(credits[0], "rect_position:x", 674, 210, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(credits[1], "rect_position:x", -326, 114, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(credits[0], "rect_position:x", 210, 114, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.4)
	tween.interpolate_property(credits[1], "rect_position:x", 114, 210, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.4)
	tween.interpolate_property(credits[0], "rect_position:x", 114, -326 - credits[0].rect_size.x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.4)
	tween.interpolate_property(credits[1], "rect_position:x", 210, 674 + credits[0].rect_size.x, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.4)
	
	set_process(false)
	tween.start()
	yield(tween, "tween_all_completed")
	set_process_input(true)
	set_process(true)
	
	time -= AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	
	delay = 2 - (float(Settings.latency) / 1000) + (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
	
	timer.wait_time =  2 - float(Settings.latency) / 1000
	
	timer.start()
	yield(timer, "timeout")
	var err = MusicPlayer.connect("finished", self, "end_game")
	if err != OK:
		get_tree().quit()
	# this should NEVER be false yet previous testing proved otherwise
	# This fixes a bug with perfect insta-restarting bullshit
	if not is_game_over:
		MusicPlayer.play()
	can_die = true

func _process(delta):
	time += delta
#	if int(time) > last_second:
#		last_second = int(time) + 5
#		time = 2 + MusicPlayer.get_playback_position() + delay + timer.time_left
	phys_time = 0
	song_progress.value = MusicPlayer.get_playback_position() / MusicPlayer.stream.get_length()

func _physics_process(delta):
	phys_time += delta
	var beat = (time + phys_time) / inverse_bps
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
		note.rect_position.y = (time - note.time) * speed * scroll_direction
		if not note.perished:
			if beat - (note.time / inverse_bps) > quarter_beat:
				if note is HoldNote:
					if note.part == 2:
						score -= 100 * multiplier * toast
						misses += 1
						note.remove_self()
						if (SongData.no_miss or SongData.perfect) and not SongData.unkillable:
							game_over()
						if combo > 0:
							combo_breaks += 1
						combo = 0
						multiplier = 1
						toast += 0.5
					elif note.part == 1 and beat - (note.time / inverse_bps) > half_beat:
						score -= 10
						note.remove_self()
						if (SongData.no_miss or SongData.perfect) and not SongData.unkillable:
							game_over()
					elif note.part == 0:
						score -= 10
						note.remove_self()
						if (SongData.no_miss or SongData.perfect) and not SongData.unkillable:
							game_over()
						if combo > 0:
							combo_breaks += 1
						combo = 0
						multiplier = 1
						toast += 0.5
				else:
					note.remove_self()
					score -= 100 * multiplier * toast
					misses += 1
					if (SongData.no_miss or SongData.perfect) and not SongData.unkillable:
						game_over()
					if combo > 0:
						combo_breaks += 1
					combo = 0
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
				if keys[0].notes[0].time / inverse_bps - beat <= 0:
					# is this the end?
					if keys[0].notes[0].part == 0:
						keys[0].holding = false
					keys[0].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
					
	if Input.is_action_pressed("key_down") and keys[1].holding:
		if keys[1].notes.size() > 0:
			if keys[1].notes[0] is HoldNote:
				if keys[1].notes[0].time / inverse_bps - beat <= 0:
					# is this the end?
					if keys[1].notes[0].part == 0:
						keys[1].holding = false
					keys[1].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
	
	if Input.is_action_pressed("key_up") and keys[2].holding:
		if keys[2].notes.size() > 0:
			if keys[2].notes[0] is HoldNote:
				if keys[2].notes[0].time / inverse_bps - beat <= 0:
					# is this the end?
					if keys[2].notes[0].part == 0:
						keys[2].holding = false
					keys[2].remove_note(0)
					score += 10 * multiplier * toast
					multiplier += 0.05
	
	if Input.is_action_pressed("key_right") and keys[3].holding:
		if keys[3].notes.size() > 0:
			if keys[3].notes[0] is HoldNote:
				if keys[3].notes[0].time / inverse_bps - beat <= 0:
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
			if keys[0].notes[0].time / inverse_bps - beat <= half_beat:
				if keys[0].notes[0] is HoldNote:
					# is it the beginning?
					if keys[0].notes[0].part == 2:
						keys[0].holding = true
						accuracy = keys[0].notes[0].time - (time + phys_time)
						keys[0].remove_note(0)
						keys[0].emit()
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[0].notes[0].time - (time + phys_time)
					keys[0].remove_note(0)
					keys[0].emit()
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
			if (keys[1].notes[0].time / inverse_bps) - beat <= half_beat:
				if keys[1].notes[0] is HoldNote:
					# is it the beginning?
					if keys[1].notes[0].part == 2:
						keys[1].holding = true
						accuracy = keys[1].notes[0].time - (time + phys_time)
						keys[1].remove_note(0)
						keys[1].emit()
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[1].notes[0].time - (time + phys_time)
					keys[1].remove_note(0)
					keys[1].emit()
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
			if (keys[2].notes[0].time / inverse_bps) - beat <= half_beat:
				if keys[2].notes[0] is HoldNote:
					# is it the beginning?
					if keys[2].notes[0].part == 2:
						keys[2].holding = true
						accuracy = keys[2].notes[0].time - (time + phys_time)
						keys[2].remove_note(0)
						keys[2].emit()
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[2].notes[0].time - (time + phys_time)
					keys[2].remove_note(0)
					keys[2].emit()
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
			if (keys[3].notes[0].time / inverse_bps) - beat <= half_beat:
				if keys[3].notes[0] is HoldNote:
					# is it the beginning?
					if keys[3].notes[0].part == 2:
						keys[3].holding = true
						accuracy = keys[3].notes[0].time - (time + phys_time)
						keys[3].remove_note(0)
						keys[3].emit()
						combo += 1
						notes_hit += 1
				else:
					accuracy = keys[3].notes[0].time - (time + phys_time)
					keys[3].remove_note(0)
					keys[3].emit()
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
		if abs(accuracy / inverse_bps) < eigth_beat:
			popup.set_popup(0)
			sweets += notes_hit
			score += notes_hit * 300 * multiplier * toast
			multiplier += 0.5
		elif SongData.perfect and not SongData.unkillable:
			game_over()
		elif abs(accuracy / inverse_bps) < sixth_beat:
			popup.set_popup(1)
			goods += notes_hit
			score += notes_hit * 150 * multiplier * toast
			multiplier += 0.1
		elif abs(accuracy / inverse_bps) < quarter_beat:
			popup.set_popup(2)
			oks += notes_hit
			score += notes_hit * 50 * multiplier * toast
		else:
			popup.set_popup(3)
			ehs += notes_hit
			score += notes_hit * 10 * multiplier * toast
			if multiplier > 1:
				multiplier -= 0.1
	if misses > 0 and SongData.perfect and not SongData.unkillable:
		game_over()
	multi_progress.value = multiplier - 1
	toast_meter.value = log(toast)
	if Settings.effects:
		spinny_bread.set_sprite(int(toast_meter.value))
	if toast > 20 and not SongData.unkillable:
		game_over()
	if toast < base_toast:
		toast = base_toast
	
	if combo > highest_combo:
		highest_combo = combo
	
	if toast > highest_toast:
		highest_toast = toast
	
	if combo > 0 and toast > 1:
		toast -= (delta / 10) * (notes_hit + 1)
	
	score_text.text = "Score: " + String(int(score))
	
	combo_text.set_combo(combo)

func end_game():
	set_physics_process(false)
	var new_results = results.instance()
	add_child(new_results)
	new_results.fade_in()

func _input(event : InputEvent):
	if event.is_action_pressed("pause") and not is_game_over:
		pause()
	elif is_game_over:
		if event.is_action_pressed("ui_accept"):
			tween.stop_all()
			timer.stop()
			MusicPlayer.stop()
			MusicPlayer.pitch_scale = 1
			var gameover = _game_over.instance()
			self.add_child(gameover)
			gameover.game_over()

func game_over():
	MusicPlayer.disconnect("finished", self, "end_game")
	is_game_over = true
	set_physics_process(false)
	set_process(false)
	if Settings.effects:
		spinny_bread.die()
		tween.interpolate_property(MusicPlayer, "pitch_scale", 1, 0, 1.0)
		tween.start()
		yield(tween, "tween_all_completed")
		timer.wait_time *= 2
		timer.start()
		yield(timer, "timeout")
		MusicPlayer.stop()
		MusicPlayer.pitch_scale = 1
	var gameover = _game_over.instance()
	if not can_die:
		yield(self, "ready")
	self.add_child(gameover)
	gameover.game_over()
