extends Control

const ASC_ICON = preload("res://sprites/descend_sort.png")
const DES_ICON = preload("res://sprites/ascend_sort.png")

onready var button = preload("res://objects/SongButton.tscn")
onready var song_selector = $CenterContainer/SongSelect

onready var sort = $Sort

var cheat_buffer : Array = []
var seq : Array = [0, 0, 1, 1, 2, 3, 2, 3, 4, 5]

var being_held : bool = false

var show_hint : bool

var all_buttons_asc : Array = []
var all_buttons_des : Array = []

class DifficultySorter:
	static func sort_ascending(button_a : SongButton, button_b : SongButton):
		if (button_a.difficulty < button_b.difficulty):
			return true
		elif (button_a.difficulty == button_b.difficulty) and (button_a.song_name < button_b.song_name):
			return true
		return false
	static func sort_descending(button_a : SongButton, button_b : SongButton):
		return !sort_ascending(button_a, button_b)

func _ready():
	MusicPlayer.set_music("res://Music/Just_Existing_v4.wav", true)
	var songs = SongData.get_songs()
	var file = File.new()
	for song in songs.keys():
		var new_button = button.instance()
		song_selector.add_child(new_button)
		new_button.set_label(song)
		if file.open(songs[song], File.READ) == OK:
			var content = JSON.parse(file.get_as_text()).result
			if content is Dictionary:
				if content.song_info.icons[0] != "" and content.song_info.icons[1] != "":
					var image1 = LoadHelper.load_image(content.song_info.icons[0])
					var image2 = LoadHelper.load_image(content.song_info.icons[1])
					if image1 != null and image2 != null:
						new_button.set_textures(image1, image2)
				new_button.set_difficulty(content.song_info.difficulty)
			file.close()
		new_button.set_trinkets(int(SongData.save_data[song].trinkets))
		if not Settings.cheats and int(SongData.save_data[song].trinkets) > 0:
			show_hint = true
		new_button.set_score(SongData.save_data[song].score)
		song_selector.remove_child(new_button)
		all_buttons_asc.append(new_button)
		new_button.button.connect("pressed", self, "play_level", [song])
	all_buttons_asc.sort_custom(DifficultySorter, "sort_ascending")
	all_buttons_des = all_buttons_asc.duplicate()
	all_buttons_des.sort_custom(DifficultySorter, "sort_descending")
	for button in all_buttons_asc:
		song_selector.add_song(button)

func _on_Back_pressed():
	TransitionManager.transition_to("title")

func play_level(song : String):
	if SongData.set_level(song):
		TransitionManager.transition_to("game")

func _on_Button_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("chart")


func _on_Sort_toggled(button_pressed):
	song_selector.remove_all_songs()
	if button_pressed:
		sort.icon = DES_ICON
		for button in all_buttons_des:
			song_selector.add_song(button)
	else:
		sort.icon = ASC_ICON
		for button in all_buttons_asc:
			song_selector.add_song(button)
