extends Node

const SAVE_PATH = "user://save.json"
const SONG_DATA_GLOABAL = "user://song_data/"

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

var speed : float = 1.0

func _ready():
	var save_file = File.new()
	if save_file.open(SAVE_PATH, File.READ) == OK:
		save_data = JSON.parse(save_file.get_as_text()).result
		save_file.close()
	load_songs()

func load_songs():
	var song_data_res = Directory.new()
	if song_data_res.open("res://song_data") == OK:
		if not song_data_res.dir_exists(SONG_DATA_GLOABAL):
			song_data_res.make_dir(SONG_DATA_GLOABAL)
		song_data_res.list_dir_begin(true)
		var file_name = song_data_res.get_next()
		var file_thing : File = File.new()
		while file_name != "":
			if not file_thing.file_exists(SONG_DATA_GLOABAL + file_name):
				song_data_res.copy("res://song_data/" + file_name, SONG_DATA_GLOABAL + file_name)
			file_name = song_data_res.get_next()
	var song_data = Directory.new()
	if song_data.open(SONG_DATA_GLOABAL) == OK:
		
		song_data.list_dir_begin(true)
		var file = File.new()
		var file_name = song_data.get_next()
		while file_name != "":
			if file_name.ends_with(".bread"):
				if file.open(SONG_DATA_GLOABAL + file_name, File.READ) == OK:
					var data = JSON.parse(file.get_as_text()).result
					if data is Dictionary:
						# Changing it so the last file loaded always gets picked as the level
#						if songs.has(data.song_info.name):
#							file_name = song_data.get_next()
#							file.close()
#							continue
						songs[data.song_info.name] = SONG_DATA_GLOABAL + file_name
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
