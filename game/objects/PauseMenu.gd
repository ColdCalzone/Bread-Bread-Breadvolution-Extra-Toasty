extends CanvasLayer

onready var resume = $CenterContainer2/VBoxContainer/Resume
onready var restart = $CenterContainer2/VBoxContainer/Restart
onready var quit = $CenterContainer2/VBoxContainer/Quit

onready var countdown = $ColorRect2
onready var label = $ColorRect2/CenterContainer/Label

onready var stuff_and_things = [$CenterContainer, $CenterContainer2]

var number : float = 3.0

enum Mode { PAUSE, OTHER }

export(Mode) var mode = Mode.PAUSE

func _physics_process(delta):
	label.text = String(ceil(number))

func pause():
	get_tree().paused = true
	match mode:
		Mode.OTHER:
			restart.visible = false
		_:
			resume.visible = true
			restart.visible = true

func _input(event):
	if event.is_action_pressed("pause"):
		for i in stuff_and_things:
			i.visible = false
		if mode == Mode.PAUSE:
			get_parent().time = 2 + MusicPlayer.get_playback_position() - AudioServer.get_time_to_next_mix() - AudioServer.get_output_latency() + (Settings.latency/1000) - get_parent().timer.time_left
			countdown.visible = true
			var tween = Tween.new()
			add_child(tween)
			tween.interpolate_property(self, "number", 3, 0, 3.0, Tween.TRANS_LINEAR)
			tween.start()
			yield(tween, "tween_all_completed")
		get_tree().paused = false
		queue_free()

func _on_Resume_pressed():
	for i in stuff_and_things:
		i.visible = false
	if mode == Mode.PAUSE:
		if get_parent().time > 0:
			get_parent().time = 2 + MusicPlayer.get_playback_position() - AudioServer.get_time_to_next_mix() - AudioServer.get_output_latency() + (Settings.latency/1000)
		countdown.visible = true
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(self, "number", 3, 0, 3.0, Tween.TRANS_LINEAR)
		tween.start()
		yield(tween, "tween_all_completed")
	get_tree().paused = false
	queue_free()

func _on_Restart_pressed():
	MusicPlayer.disconnect("finished", get_parent(), "end_game")
	MusicPlayer.stop()
	TransitionManager.transition_to("game")
	get_tree().paused = false
	queue_free()

func _on_Quit_pressed():
	MusicPlayer.disconnect("finished", get_parent(), "end_game")
	MusicPlayer.stop()
	TransitionManager.transition_to("play")
	get_tree().paused = false
	queue_free()
