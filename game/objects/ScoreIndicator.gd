extends Control

onready var timer = $Timer
onready var sprite = $Sprite


enum ScoreIndicator {SWEET = 0, GOOD = 1, OK = 2, EH = 3}
var current_popup = ScoreIndicator.SWEET

var time = 0

func set_popup(type : int):
	timer.stop()
	current_popup = type
	sprite.region_rect = Rect2(0, 32 * current_popup, 64, 32)
	sprite.visible = true
	sprite.offset.y = 0
	set_process(Settings.effects)
	timer.start()

func _process(delta):
	sprite.offset.y -= delta * 20
	time += delta * 6
	match current_popup:
		ScoreIndicator.SWEET, ScoreIndicator.EH:
			sprite.region_rect.position.x = (int(time) % 5) * 64
		ScoreIndicator.GOOD:
			sprite.region_rect.position.x = (int(time) % 4) * 64
		ScoreIndicator.OK:
			sprite.region_rect.position.x = (int(time) % 2) * 64


func _on_Timer_timeout():
	set_process(false)
	sprite.visible = false
	time = 0
