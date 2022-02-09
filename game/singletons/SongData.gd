extends Node

var current_level : String

var songs : Dictionary = {
	
}

func _ready():
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
					if songs.has(data.song_info.name): continue
					songs[data.song_info.name] = "res://song_data/" + file_name
				file.close()
			file_name = song_data.get_next()

func get_level() -> String:
	return current_level

func set_level(level : String) -> bool:
	if songs.has(level):
		current_level = songs[level]
		return true
	return false

func get_songs() -> Dictionary:
	return songs
