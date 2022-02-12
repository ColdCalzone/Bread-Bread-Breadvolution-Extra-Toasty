extends HBoxContainer

onready var button : TextureButton = $TextureButton
onready var label = $TextureButton/CenterContainer/Label
onready var score = $VBoxContainer/Score
onready var trinkets = $VBoxContainer/Trinkets.get_children()

enum Trinkets {COMPLETE = 1, BLIND = 2, NOMISS = 4, PERFECT = 8}

func set_textures(default : Texture, clicked : Texture):
	button.texture_normal = default
	button.texture_focused = clicked
	label.visible = false

func set_label(text):
	label.visible = true
	label.text = String(text)

func set_score(amount):
	score.text = "Score: " + String(amount)

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
