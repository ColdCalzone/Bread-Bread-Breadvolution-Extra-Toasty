extends Node

var audio_loader = AudioLoader.new()

func load_image(path : String) -> Texture:
	if path.begins_with("res://"):
		return load(path) as Texture
	else:
		var image = Image.new()
		image.load(path)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		return texture

func load_audio(path : String) -> AudioStream:
	if path.begins_with("res://"):
		return load(path) as AudioStream
	else:
		# Let it be known that on this day, 15/2/22, I want now more than ever before, to kill
		#every single person who has contributed to Godot.
		# Who decided that loading resources from user:// wouldn't be allowed, but instead
		#one must open the file, get the bytes of it, and create the resource manually?
		# A fool and a moron, that's who.
		return audio_loader.loadfile(path)
