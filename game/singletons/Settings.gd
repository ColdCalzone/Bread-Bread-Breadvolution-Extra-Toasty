extends Node

const CONFIG_PATH = "user://settings.cfg"

var music_volume : float = 1.0 setget set_music_volume
var sound_volume : float = 1.0 setget set_sound_volume
var fullscreen : bool = false setget set_fullscreen
var show_fps : bool = true setget set_fps
var latency : int = 0

var config : ConfigFile

func load_config():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		err = config.save(CONFIG_PATH)
	if err == OK:
		set_music_volume(config.get_value("sound", "music_volume", 1.0))
		set_sound_volume(config.get_value("sound", "sound_volume", 1.0))
		set_fullscreen(config.get_value("video", "fullscreen", false))
		set_fps(config.get_value("video", "show_fps", true))
		latency = config.get_value("game", "latency", 0)

func save_config():
	config.set_value("sound", "music_volume", music_volume)
	config.set_value("sound", "sound_volume", sound_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "show_fps", show_fps)
	config.set_value("game", "latency", latency)
	config.save(CONFIG_PATH)

func set_music_volume(value):
	music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))

func set_sound_volume(value):
	sound_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sound_volume))

func set_fullscreen(value):
	fullscreen = value
	OS.set_window_fullscreen(fullscreen)

func set_fps(value):
	show_fps = value
	if show_fps:
		FPS.show_fps()
	else:
		FPS.hide_fps()