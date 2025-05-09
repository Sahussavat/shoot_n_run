extends Control

@onready var skip_bar = $ProgressBar
@onready var skip_label = $HBoxContainer/skip_key
var done_skip = false
var enable_skip = false
@export var is_instant_skip = false

signal on_finished_skip

func _ready():
	show_skip_key()
	skip_bar.value_changed.connect(on_skip_bar_changed)

func _process(_delta):
	if KeyUtill.is_pressing(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.MENU]) and enable_skip:
		if is_instant_skip:
			visible = false
			done_skip = true
			on_finished_skip.emit()
		else:
			skip_bar.value = skip_bar.value + 2
	else:
		skip_bar.value = skip_bar.value - 2

func on_skip_bar_changed(val):
	var v = clamp(val, 0, skip_bar.max_value)
	if v <= 0 or done_skip:
		visible = false
	else:
		visible = true
	
	if v >= skip_bar.max_value:
		done_skip = true
		on_finished_skip.emit()

func reset_skip_bar():
	skip_bar.value = 0

func show_skip_key():
	skip_label.text = "[ " + GameControlKeycode.get_string(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.MENU]) + " ]"
