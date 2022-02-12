extends Node

const CONFIG_PATH = "user://settings.cfg"

enum ScrollDirections {UP = -1, DOWN = 1}

var music_volume : float = 1.0 setget set_music_volume
var sound_volume : float = 1.0 setget set_sound_volume
var fullscreen : bool = false setget set_fullscreen
var show_fps : bool = true setget set_fps
var latency : float = 0
var backgrounds : bool = true setget set_background
var scroll : int = ScrollDirections.DOWN
var effects : bool = true

var cheats : bool = false

var key_binds : Array = [68, 70, 74, 75]

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
		effects = config.get_value("video", "effects", true)
		set_fps(config.get_value("video", "show_fps", true))
		set_background(config.get_value("video", "backgrounds", true))
		latency = config.get_value("game", "latency", 0)
		scroll = config.get_value("game", "scroll", ScrollDirections.DOWN)
		cheats = config.get_value("game", "cheats", false)
		
		key_binds = config.get_value("game", "keybinds", [68, 70, 74, 75])
		var left = InputEventKey.new()
		left.scancode = key_binds[0]
		InputMap.action_erase_events("key_left")
		InputMap.action_add_event("key_left", left)
		
		var down = InputEventKey.new()
		down.scancode = key_binds[1]
		InputMap.action_erase_events("key_down")
		InputMap.action_add_event("key_down", down)
		
		var up = InputEventKey.new()
		up.scancode = key_binds[2]
		InputMap.action_erase_events("key_up")
		InputMap.action_add_event("key_up", up)
		
		var right = InputEventKey.new()
		right.scancode = key_binds[3]
		InputMap.action_erase_events("key_right")
		InputMap.action_add_event("key_right", right)

func save_config():
	config.set_value("sound", "music_volume", music_volume)
	config.set_value("sound", "sound_volume", sound_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "show_fps", show_fps)
	config.set_value("video", "backgrounds", backgrounds)
	config.set_value("game", "latency", latency)
	config.set_value("game", "scroll", scroll)
	config.set_value("video", "effects", effects)
	config.set_value("game", "keybinds", key_binds)
	config.set_value("game", "cheats", cheats)
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

func set_background(value):
	backgrounds = value

func set_cheat_mode():
	cheats = true
	save_config()
