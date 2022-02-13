extends ColorRect

const TOAST = preload("res://objects/Toast.tscn")
const TOAST_POS = -128

onready var fade = $Fade
onready var tween = $Tween

onready var score = $Summary/Score
onready var combo = $Summary/Combo
onready var breaks = $Summary/Breaks
onready var accuracy = $Summary/Accuracy
onready var toast = $Summary/Toast

onready var sweets = $CenterContainer/GridContainer/Sweet/Label
onready var goods = $CenterContainer/GridContainer/Good/Label
onready var oks = $CenterContainer/GridContainer/Ok/Label
onready var ehs = $CenterContainer/GridContainer/Eh/Label

var game : Control

func _ready():
	pass # Replace with function body.

func fade_in():
	tween.interpolate_property(fade, "modulate:a", 1.0, 0.0, 0.3)
	tween.start()
	game = get_parent()
	sweets.text = String(game.sweets)
	goods.text = String(game.goods)
	oks.text = String(game.oks)
	ehs.text = String(game.ehs)
	combo.text += String(game.highest_combo)
	breaks.text += String(game.combo_breaks)
	accuracy.text += String(
		stepify(100 * (float((4 * game.sweets) + (3 * game.goods) + (2 * game.oks) + (game.ehs)) / float(4 * game.total_notes + game.misses)), 0.01)
	) + "%"
	toast.text += String(stepify(game.highest_toast, 0.1))
	score.text += String(int(game.score))
	var toast_objs = []
	var current_trinkets = int(SongData.save_data[SongData.level_name].trinkets)
	if (current_trinkets & 1) == 0:
		var new_toast = TOAST.instance()
		add_child(new_toast)
		new_toast.rect_position.y = TOAST_POS
		new_toast.set_icon(SongData.toast_data[SongData.level_name]["completed"]["icon"])
		new_toast.set_title(SongData.toast_data[SongData.level_name]["completed"]["title"])
		new_toast.set_subtitle(SongData.toast_data[SongData.level_name]["completed"]["subtitle"])
		toast_objs.append(new_toast)
	if (current_trinkets & 2) == 0 and SongData.blind:
		var new_toast = TOAST.instance()
		add_child(new_toast)
		new_toast.rect_position.y = TOAST_POS
		new_toast.set_icon(SongData.toast_data[SongData.level_name]["blind"]["icon"])
		new_toast.set_title(SongData.toast_data[SongData.level_name]["blind"]["title"])
		new_toast.set_subtitle(SongData.toast_data[SongData.level_name]["blind"]["subtitle"])
		toast_objs.append(new_toast)
	if (current_trinkets & 4) == 0 and SongData.no_miss:
		var new_toast = TOAST.instance()
		add_child(new_toast)
		new_toast.rect_position.y = TOAST_POS
		new_toast.set_icon(SongData.toast_data[SongData.level_name]["nomiss"]["icon"])
		new_toast.set_title(SongData.toast_data[SongData.level_name]["nomiss"]["title"])
		new_toast.set_subtitle(SongData.toast_data[SongData.level_name]["nomiss"]["subtitle"])
		toast_objs.append(new_toast)
	if (current_trinkets & 8) == 0 and SongData.perfect:
		var new_toast = TOAST.instance()
		add_child(new_toast)
		new_toast.rect_position.y = TOAST_POS
		new_toast.set_icon(SongData.toast_data[SongData.level_name]["perfect"]["icon"])
		new_toast.set_title(SongData.toast_data[SongData.level_name]["perfect"]["title"])
		new_toast.set_subtitle(SongData.toast_data[SongData.level_name]["perfect"]["subtitle"])
		toast_objs.append(new_toast)
	for toast_obj in range(toast_objs.size()):
		toast_objs[toast_obj].slide_in(toast_obj * 128)
		yield(get_tree().create_timer(0.1), "timeout")
	if not (SongData.aim_bot or SongData.unkillable):
		SongData.save_to_file(int(game.score))
	yield(tween, "tween_all_completed")
	

func _on_Restart_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("game")
	get_tree().paused = false
	queue_free()

func _on_Quit_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("play")
	get_tree().paused = false
	queue_free()
