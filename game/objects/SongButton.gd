extends TextureButton

onready var label = $CenterContainer/Label

func set_textures(default : Texture, clicked : Texture):
	self.texture_normal = default
	self.texture_focused = clicked
	label.visible = false

func set_label(text : String):
	label.visible = true
	label.text = text
