extends AudioStreamPlayer

func set_music(audio_path, play : bool = false, loop : bool = false):
	var audio
	if audio_path is String:
		audio = LoadHelper.load_audio(audio_path, loop)
	elif audio_path is AudioStream:
		audio = audio_path
	if self.stream != audio:
		self.stream = audio
		if play:
			self.play()
