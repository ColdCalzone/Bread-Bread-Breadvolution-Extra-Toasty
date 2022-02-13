extends Control

onready var tween = $Tween
onready var panel = $Panel

onready var cheats = $Panel/ScrollContainer/VBoxContainer.get_children()

var open : bool = false

func _ready():
	cheats[0].pressed = SongData.blind
	cheats[1].pressed = SongData.no_miss
	cheats[2].pressed = SongData.perfect
	cheats[3].pressed = SongData.aim_bot
	cheats[4].pressed = SongData.unkillable
	for button in cheats:
		button.connect("toggled", self, "set_cheat", [button.name])

func _on_Button_button_down():
	if tween.is_active():
		return
	open = !open
	if open:
		tween.interpolate_property(panel, "rect_position", Vector2.ZERO, Vector2.LEFT * 217, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.start()
	else:
		tween.interpolate_property(panel, "rect_position", Vector2.LEFT * 217, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		tween.start()

func set_cheat(button_pressed : bool, cheat : String):
	if cheat == "NoMiss" and button_pressed:
		cheats[2].pressed = false
		#cheats[3].pressed = false
		#cheats[4].pressed = false
	if cheat == "Perfect" and button_pressed:
		cheats[1].pressed = false
		#cheats[3].pressed = false
		#cheats[4].pressed = false
	#if (cheat == "Aimbot" or cheat == "Unkillable") and button_pressed:
		#cheats[0].pressed = false
		#cheats[1].pressed = false
		#cheats[2].pressed = false
	SongData.set_cheats([cheats[0].pressed, cheats[1].pressed, cheats[2].pressed, cheats[3].pressed, cheats[4].pressed])
