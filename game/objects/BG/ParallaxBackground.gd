extends ParallaxBackground

export(int) var speed = 50

func _ready():
	set_enabled(Settings.backgrounds)

func set_enabled(enabled : bool):
	set_process(enabled)
	for node in get_children():
		if node is ParallaxLayer:
			node.visible = enabled

func _process(delta):
	scroll_offset.x += speed * delta
