extends CanvasLayer

func game_over():
	MusicPlayer.stop()
	get_tree().paused = true


func _on_Restart_pressed():
	TransitionManager.transition_to("game")
	get_tree().paused = false
	queue_free()


func _on_Quit_pressed():
	TransitionManager.transition_to("play")
	get_tree().paused = false
	queue_free()
