extends Panel

class_name Toast

# Isn't it funny how I'm adding Toasts to this game about BREAD. FUNNY. LAUGH AT HOW FUNNY I AM

onready var title = $VBoxContainer/Title
onready var flavor = $VBoxContainer/Flavor
onready var icon = $CenterContainer/Icon
onready var tween = $Tween
onready var audio = $Audio

# TODO fix this up so you can just call Toast.new() to make a new one
func _ready():
	if get_child_count() == 0:
		tween = Tween.new()
		var center = CenterContainer.new()
		icon = TextureRect.new()
		center.add_child(icon)
		var vbox = VBoxContainer.new()
		vbox.add_constant_override("seperation", 9)
		var karmatic : DynamicFont = load("res://src/Karmatic.tres").duplicate(true)
		karmatic.size = 16
		title = Label.new()
		flavor = Label.new()
		title.add_font_override("font", karmatic)
		vbox.add_child(title)
		karmatic = karmatic.duplicate(true)
		karmatic.extra_spacing_bottom = -2
		karmatic.extra_spacing_top = -2
		karmatic.size = 10
		flavor.add_font_override("font", karmatic)
		vbox.add_child(flavor)
		self.add_child(tween)
		self.add_child(center)
		self.add_child(vbox)
		center.rect_size = Vector2(96, 128)
		vbox.rect_size = Vector2(157, 122)
		vbox.rect_position = Vector2(96, 3)
		self.visible = false
	self.rect_size = Vector2(256, 128)

func set_icon(new_icon):
	if new_icon is String:
		new_icon = load(new_icon)
	icon.texture = new_icon

func set_flavor(text : String):
	flavor.text = text

func set_subtitle(text : String):
	set_flavor(text)

func set_title(text : String):
	title.text = text

func slide_in(offset : float = 0):
	self.visible = true
	tween.interpolate_property(self, "rect_position:y", rect_position.y + offset, rect_position.y + offset + 128, 0.3)
	tween.interpolate_property(self, "rect_position:y", rect_position.y + offset + 128, rect_position.y, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 4.0)
	tween.start()
	yield(tween, "tween_completed")
	audio.play()
