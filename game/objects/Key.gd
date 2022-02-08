extends Control

onready var sprite = $Sprite

onready var normal = preload("res://sprites/bread_outline.png")
onready var pulse = preload("res://sprites/bread_pulse.png")

onready var note = preload("res://objects/Note.tscn")
onready var hold_note = preload("res://objects/HoldNote.tscn")

enum Direction {UP, RIGHT, DOWN, LEFT}

export(Direction) var direction = Direction.UP

var notes : Array = []

var speed = 1

# Used for hold note detection
var holding : bool = false

func _ready():
	sprite.region_rect.position.x = direction * 64

func press():
	sprite.texture = pulse
	sprite.scale = Vector2.ONE * 0.9

func release():
	sprite.texture = normal
	sprite.scale = Vector2.ONE

func spawn_note(target_time):
	var new_note = note.instance()
	new_note.time = target_time
	new_note.direction = direction
	self.add_child(new_note)
	self.notes.append(new_note)
	new_note.visible = true

func spawn_hold(target_start, target_end):
	var new_note = hold_note.instance()
	new_note.time = target_start
	new_note.part = new_note.Part.BEGIN
	var end_note = hold_note.instance()
	end_note.time = target_end
	end_note.part = end_note.Part.END
	self.add_child(new_note)
	self.add_child(end_note)
	self.notes.append(new_note)
	# measured in pixels per second
	var distance = 64/speed
	while distance < (target_end - target_start) - 64/speed:
		var middle_note = hold_note.instance()
		middle_note.part = middle_note.Part.MIDDLE
		middle_note.time = target_start + distance
		#var temp_var_for_middle_note_thingy = middle_note.duplicate()
		self.add_child(middle_note)
		self.notes.append(middle_note)
		distance += 64/speed
		
	self.notes.append(end_note)

func remove_note(which):
	self.notes[which].queue_free()
	self.notes.remove(which)
