extends Node

onready var discord : Discord.Core = Discord.Core.new()
var activities : Discord.ActivityManager = null

enum GameState {
	TITLE = 0,
	IN_GAME = 1,
	PAUSED = 2,
	CHARTING = 3,
}

var current_state = GameState.TITLE

func _ready():
	var result = discord.create(945567902180970546, Discord.CreateFlags.NO_REQUIRE_DISCORD)
	if result != Discord.Result.OK:
		print("Error initializing Discord Core: ", result)
		discord = null
		return
	activities = discord.get_activity_manager()

func run_callbacks():
	if discord != null:
		discord.run_callbacks()

func set_activity(score : int = 0, end_time : int = 0):
	if activities == null: return
	var activity = Discord.Activity.new()
	activity.assets.large_image = "gameicon"
	match current_state:
		GameState.TITLE:
			activity.state = "On Titlescreen"
			activity.assets.small_image = "None"
		GameState.IN_GAME:
			activity.state = "Score: " + String(score)
			activity.timestamps.end = end_time
			match SongData.level_name:
				"Loadout":
					activity.assets.small_image = "loadouticon"
					activity.assets.small_text = "Loadout"
				"Into the swing":
					activity.assets.small_image = "swingicon"
					activity.assets.small_text = "Into the Swing - Hard"
				"Into the Swing":
					activity.assets.small_image = "swingicon"
					activity.assets.small_text = "Into the Swing - Easy"
				"Going Up":
					activity.assets.small_image = "goingupicon"
					activity.assets.small_text = "Going Up"
				"Descent":
					activity.assets.small_image = "descenticon"
					activity.assets.small_text = "Descent"
				_:
					activity.assets.small_image = "None"
					activity.assets.small_text = SongData.level_name
		GameState.PAUSED:
			activity.state = "Paused..."
			match SongData.level_name:
				"Loadout":
					activity.assets.small_image = "loadouticon"
					activity.assets.small_text = "Loadout"
				"Into the swing":
					activity.assets.small_image = "swingicon"
					activity.assets.small_text = "Into the Swing - Hard"
				"Into the Swing":
					activity.assets.small_image = "swingicon"
					activity.assets.small_text = "Into the Swing - Easy"
				"Going Up":
					activity.assets.small_image = "goingupicon"
					activity.assets.small_text = "Going Up"
				"Descent":
					activity.assets.small_image = "descenticon"
					activity.assets.small_text = "Descent"
				_:
					activity.assets.small_image = "None"
					activity.assets.small_text = SongData.level_name
		GameState.CHARTING:
			activity.details = "Charting"
			activity.state = "Being a massive nerd"
	if activity.details.length() <= 0:
		var cheats = ""
		if SongData.blind:
			cheats += "| BLIND "
		if SongData.no_miss:
			cheats += "| NOMISS "
		if SongData.perfect:
			cheats += "| PERFECT "
		if SongData.aim_bot:
			cheats += "| AIMBOT "
		if SongData.unkillable:
			cheats += "| NOFAIL "
		if cheats.length() > 0:
			cheats.erase(0, 2)
		activity.details = cheats
	
	activities.update_activity(activity, self, "_update_activities_callback")

func _update_activities_callback(result : int):
	if result != Discord.Result.OK:
		print("Failed to update activity", result)
		return
