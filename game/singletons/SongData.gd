extends Node

const SAVE_PATH = "user://save.json"

var save_data : Dictionary = {
	
}

var current_level : String

var toast_data : Dictionary = {
	
}

var level_name : String

var songs : Dictionary = {
	
}

var blind : bool = false
var no_miss : bool = false
var perfect : bool = false

var aim_bot : bool = false
var unkillable : bool = false

func _ready():
	var save_file = File.new()
	if save_file.open(SAVE_PATH, File.READ) == OK:
		save_data = JSON.parse(save_file.get_as_text()).result
		save_file.close()
	load_songs()

func load_songs():
	var song_data = Directory.new()
	if song_data.open("res://song_data/") == OK:
		song_data.list_dir_begin(true)
		var file = File.new()
		var file_name = song_data.get_next()
		while file_name != "":
			if file.open("res://song_data/" + file_name, File.READ) == OK:
				var data = JSON.parse(file.get_as_text()).result
				if data is Dictionary:
					if songs.has(data.song_info.name):
						file_name = song_data.get_next()
						file.close()
						continue
					songs[data.song_info.name] = "res://song_data/" + file_name
					toast_data[data.song_info.name] = data["toasts"]
					if save_data.has(data.song_info.name):
						file_name = song_data.get_next()
						file.close()
						continue
					save_data[data.song_info.name] = {
						"score" : 0,
						"trinkets": 0,
					}
				file.close()
			file_name = song_data.get_next()

func save_to_file(score):
	if save_data[level_name]["score"] < score:
		save_data[level_name]["score"] = score
	var trinkets = int(save_data[level_name]["trinkets"]) | (1 + (int(blind) * 2) + (int(no_miss or perfect) * 4) + (int(perfect) * 8))
	save_data[level_name]["trinkets"] = trinkets
	var save_file = File.new()
	if save_file.open(SAVE_PATH, File.WRITE) == OK:
		save_file.store_string(JSON.print(save_data))
		save_file.close()

func get_level() -> String:
	return current_level

func set_level(level : String) -> bool:
	if songs.has(level):
		current_level = songs[level]
		level_name = level
		return true
	return false

func get_songs() -> Dictionary:
	return songs

func set_cheats(cheats : Array):
	blind = cheats[0]
	no_miss = cheats[1]
	perfect = cheats[2]
	aim_bot = cheats[3]
	unkillable = cheats[4]
