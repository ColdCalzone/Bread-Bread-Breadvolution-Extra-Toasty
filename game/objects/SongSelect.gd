extends ScrollContainer

onready var vbox = $VBoxContainer

func _ready():
	if get_parent() is Control:
		self.rect_min_size.x = get_parent().rect_size.x

func add_song(button):
	vbox.add_child(button)
	if button is Control and self.rect_min_size.y < 360:
		var extra_space = button.rect_min_size.y + 4 # Vbox seperation 
		if extra_space + self.rect_min_size.y < 360:
			self.rect_min_size.y += extra_space
		else:
			self.rect_min_size.y = 360


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
