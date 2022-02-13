extends Control

var sweets = 0
var goods = 0
var oks = 0
var ehs = 0
var misses = 1
var highest_combo = 0
var combo_breaks = 0
var highest_toast = 0
var score = 69
var total_notes = 1

func _ready():
	SongData.unkillable = true
	$ResultsScreen.fade_in()
