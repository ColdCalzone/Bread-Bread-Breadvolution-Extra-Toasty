extends AudioStreamPlayer

func set_music(audio_path, play : bool = false):
	var audio
	if audio_path is String:
		audio = load(audio_path)
	elif audio_path is AudioStream:
		audio = audio_path
	self.stream = audio
	if play:
		self.play()
