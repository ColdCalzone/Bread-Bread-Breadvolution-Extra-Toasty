extends HBoxContainer

class_name SongButton

onready var button : TextureButton = $TextureButton
onready var label = $TextureButton/CenterContainer/Label
var song_name : String = ""
onready var score = $VBoxContainer/Score
onready var trinkets = $VBoxContainer/HBoxContainer/Trinkets.get_children()

onready var difficulty_label = $VBoxContainer/HBoxContainer/VBoxContainer/Difficulty
var difficulty : int = 0

enum Trinkets {COMPLETE = 1, BLIND = 2, NOMISS = 4, PERFECT = 8}

func set_textures(default : Texture, clicked : Texture):
	button.texture_normal = default
	button.texture_focused = clicked
	label.visible = false

func set_label(text):
	label.visible = true
	song_name = String(text)
	label.text = song_name

func set_score(amount):
	score.text = "Score: " + String(amount)

func set_difficulty(level):
	difficulty = level
	difficulty_label.text = "LVL: " + String(level)

func set_trinkets(trinket_bits):
	trinket_bits = int(trinket_bits)
	# Why the fuck do I need to do this
	# It just sets them all to true otherwise
	if trinket_bits == 0:
		for trinket in trinkets:
			trinket.visible = false
	else:
		trinkets[0].visible = (trinket_bits & Trinkets.COMPLETE) == Trinkets.COMPLETE
		trinkets[1].visible = (trinket_bits & Trinkets.BLIND) == Trinkets.BLIND
		trinkets[2].visible = (trinket_bits & Trinkets.NOMISS) == Trinkets.NOMISS
		trinkets[3].visible = (trinket_bits & Trinkets.PERFECT) == Trinkets.PERFECT
