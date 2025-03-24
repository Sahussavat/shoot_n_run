extends Control

@onready var skip_container = $skip_container
@onready var skip_bar = $skip_container/ProgressBar
@onready var skip_label = $skip_container/HBoxContainer/skip_key
var done_skip = false
# Called when the node enters the scene tree for the first time.
func _ready():
	show_skip_key()
	skip_bar.value_changed.connect(on_skip_bar_changed)


func _process(_delta):
	if Input.is_physical_key_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.MENU]):
		skip_bar.value = skip_bar.value + 2
	else:
		skip_bar.value = skip_bar.value - 2
func on_skip_bar_changed(val):
	var v = clamp(val, 0, skip_bar.max_value)
	if v <= 0 or done_skip:
		skip_container.visible = false
	else:
		skip_container.visible = true
	
	if v >= skip_bar.max_value:
		done_skip = true
		end()

func end():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(change_to_world)

func change_to_world():
	await get_tree().create_timer(0.1).timeout
	ChangePage.change_to_target_scene("res://nodes/worlds/score.tscn")

func show_skip_key():
	skip_label.text = "[ " + OS.get_keycode_string(GameControlKeycode.current_key[GameControlKeycode.KEY.MENU]) + " ]"
