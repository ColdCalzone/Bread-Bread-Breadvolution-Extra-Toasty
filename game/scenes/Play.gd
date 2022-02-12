extends Control

onready var button = preload("res://objects/SongButton.tscn")
onready var song_selector = $CenterContainer/SongSelect

onready var chart_button = $ChartEditor
onready var cheats = $CheatMenu

var cheat_buffer : Array = []
var seq : Array = [0, 0, 1, 1, 2, 3, 2, 3, 4, 5]

var being_held : bool = false

func _ready():
	if Settings.cheats:
		cheats.rect_position.x -= 20
		chart_button.rect_position.x -= 20
	var songs = SongData.get_songs()
	var file = File.new()
	for song in songs.keys():
		var new_button = button.instance()
		song_selector.add_child(new_button)
		new_button.set_label(song)
		var textures : Array = []
		if file.open(songs[song], File.READ) == OK:
			var content = JSON.parse(file.get_as_text()).result
			if content is Dictionary:
				if content.song_info.icons[0] != "" and content.song_info.icons[1] != "":
					new_button.set_textures(load(content.song_info.icons[0]), load(content.song_info.icons[1]))
			file.close()
		new_button.set_trinkets(int(SongData.save_data[song].trinkets))
		new_button.set_score(SongData.save_data[song].score)
		song_selector.remove_child(new_button)
		song_selector.add_song(new_button)
		
		new_button.button.connect("pressed", self, "play_level", [song])

func _on_Back_pressed():
	TransitionManager.transition_to("title")

func play_level(song : String):
	if SongData.set_level(song):
		TransitionManager.transition_to("game")

func _input(event):
	if event is InputEventKey and not Settings.cheats:
		if event.pressed and not event.echo:
			match event.scancode:
				KEY_UP:
					cheat_buffer.push_back(0)
				KEY_DOWN:
					cheat_buffer.push_back(1)
				KEY_LEFT:
					cheat_buffer.push_back(2)
				KEY_RIGHT:
					cheat_buffer.push_back(3)
				KEY_B:
					cheat_buffer.push_back(4)
				KEY_A:
					cheat_buffer.push_back(5)
				KEY_ENTER:
					var offset = 0
					for key in cheat_buffer:
						if key == seq[offset]:
							offset += 1
							if offset == 10:
								Settings.set_cheat_mode()
								cheats.rect_position.x -= 20
								chart_button.rect_position.x -= 20


func _on_Button_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("chart")
