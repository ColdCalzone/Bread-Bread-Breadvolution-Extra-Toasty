extends HBoxContainer

onready var button : TextureButton = $TextureButton
onready var label = $TextureButton/CenterContainer/Label
onready var score = $VBoxContainer/Score
onready var trinkets = $VBoxContainer/Trinkets.get_children()

func set_textures(default : Texture, clicked : Texture):
	button.texture_normal = default
	button.texture_focused = clicked
	label.visible = false

func set_label(text : String):
	label.visible = true
	label.text = text
