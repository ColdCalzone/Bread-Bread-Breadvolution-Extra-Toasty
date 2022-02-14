extends CanvasLayer

onready var restart = $CenterContainer2/VBoxContainer/Restart
onready var quit = $CenterContainer2/VBoxContainer/Quit

func game_over():
	MusicPlayer.stop()
	get_tree().paused = true

func _on_Restart_pressed():
	restart.disabled = true
	quit.disabled = true
	MusicPlayer.stop()
	TransitionManager.transition_to("game")
	get_tree().paused = false


func _on_Quit_pressed():
	restart.disabled = true
	quit.disabled = true
	TransitionManager.transition_to("play")
	get_tree().paused = false
