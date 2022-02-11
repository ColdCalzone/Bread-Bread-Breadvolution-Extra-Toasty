extends ColorRect

onready var fade = $Fade
onready var tween = $Tween

onready var score = $Summary/Score
onready var combo = $Summary/Combo
onready var breaks = $Summary/Breaks
onready var accuracy = $Summary/Accuracy

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
		stepify(100 * (float((4 * game.sweets) + (3 * game.goods) + (2 * game.oks) + (game.ehs)) / float(4 * game.total_notes)), 0.01)
	) + "%"
	score.text += String(int(game.score))

func _on_Restart_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("game")
	get_tree().paused = false
	queue_free()

func _on_Quit_pressed():
	MusicPlayer.stop()
	TransitionManager.transition_to("title")
	get_tree().paused = false
	queue_free()
