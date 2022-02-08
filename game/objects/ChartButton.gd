tool
extends Panel

class_name ChartButton

var texture : TextureRect

enum Direction {LEFT, DOWN, UP, RIGHT}

enum Mode {NONE = 0, NORMAL = 1, HOLD = 2, END = 3, HOLD_MID = 4}

export(Direction) var current_direction = Direction.LEFT

var current_mode = Mode.NONE

var pressed = false

export(StreamTexture) onready var normal_note = preload("res://sprites/bread_left.png")
export(StreamTexture) onready var hold_start = preload("res://sprites/baguette_start.png")
export(StreamTexture) onready var hold_middle = preload("res://sprites/baguette_mid.png")
export(StreamTexture) onready var hold_end = preload("res://sprites/baguette_end.png")

signal pressed(mode)

# I hate this
func _ready():
	if get_child_count() == 0:
		self.texture = TextureRect.new()
		self.texture.expand = true
		self.texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		add_child(self.texture)
	else:
		self.texture = $TextureRect
	self.texture.rect_size = self.rect_size

func set_mode(mode : int):
	if current_mode == mode or !self.pressed:
		self.pressed = !self.pressed
	match mode:
		Mode.NORMAL:
			self.texture.texture = self.normal_note
			self.current_mode = self.Mode.NORMAL
		Mode.HOLD:
			self.texture.texture = self.hold_start
			self.current_mode = self.Mode.HOLD
		Mode.END:
			self.texture.texture = self.hold_end
			self.current_mode = self.Mode.END
		Mode.HOLD_MID:
			self.texture.texture = self.hold_middle
			self.current_mode = self.Mode.HOLD_MID
		Mode.NONE:
			self.pressed = false
			
	if !self.pressed:
		self.current_mode = self.Mode.NONE
		self.texture.texture = null

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if !event.pressed or event.button_index > 3 or self.current_mode == self.Mode.HOLD_MID:
			return
		emit_signal("pressed", event.button_index * int(!self.pressed))

func _on_resized():
	if !Engine.editor_hint:
		self.texture.rect_size = self.rect_size
	else:
		get_child(0).rect_size = self.rect_size
