extends CanvasLayer

var scenes = {
	"title" : preload("res://scenes/Titlescreen.tscn"),
	"settings" : preload("res://scenes/Settings.tscn"),
	"chart" : preload("res://scenes/ChartEditor.tscn"),
	"play" : preload("res:///scenes/Play.tscn"),
	"game" : preload("res://scenes/Game.tscn"),
	"credits" : preload("res://scenes/Credits.tscn")
}

onready var tween = $TransitionManager/Tween
onready var rect = $TransitionManager

func transition_to(scene):
	if scene is String:
		if !scenes.has(scene):
			scene = load(scene)
		else:
			scene = scenes[scene]
	if not scene is PackedScene:
		return false
	tween.interpolate_property(rect, "color:a", 0.0, 1.0, 0.2)
	tween.interpolate_property(rect, "color:a", 1.0, 0.0, 0.2, 0, 2, 0.2)
	tween.start()
	yield(tween, "tween_completed")
	get_tree().change_scene_to(scene)
