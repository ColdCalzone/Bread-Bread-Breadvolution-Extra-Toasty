extends Control

onready var button = preload("res://objects/SongButton.tscn")
onready var song_selector = $CenterContainer/SongSelect

func _ready():
	var songs = SongData.get_songs()
	var file = File.new()
	for song in songs.keys():
		var new_button = button.instance()
		song_selector.add_child(new_button)
		new_button.set_label(song)
		if file.open(songs[song], File.READ) == OK:
			var content = JSON.parse(file.get_as_text()).result
			if content is Dictionary:
				if content.song_info.icons[0] != null and content.song_info.icons[1] != null:
					new_button.set_textures(load(content.song_info.icons[0]), load(content.song_info.icons[1]))
			file.close()
		song_selector.add_song(button)
		new_button.button.connect("pressed", self, "play_level", [song])

func _on_Back_pressed():
	TransitionManager.transition_to("title")

func play_level(song : String):
	if SongData.set_level(song):
		TransitionManager.transition_to("game")
