extends Control

@onready var video_player = $cutscene
@onready var skip_container = $skip_container
@onready var skip_label = $skip_container/HBoxContainer/skip_key
@onready var skip_bar = $skip_container/ProgressBar
@onready var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
var temp_menu_process_mode = PROCESS_MODE_INHERIT

# Called when the node enters the scene tree for the first time.
func _ready():
	show_skip_key()
	add_to_group(GroupsName.CUTSCENE)
	video_player.finished.connect(on_finished)
	skip_bar.value_changed.connect(on_skip_bar_changed)
	process_mode = Node.PROCESS_MODE_ALWAYS
	if menu:
		temp_menu_process_mode = menu.process_mode
	if video_player.autoplay:
		play_video()

func _process(_delta):
	if Input.is_physical_key_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.MENU]):
		skip_bar.value = skip_bar.value + 2
	else:
		skip_bar.value = skip_bar.value - 2

func on_finished():
	if video_player.is_playing():
		video_player.stop()
	get_tree().paused = false
	visible = false
	menu.process_mode = temp_menu_process_mode

func play_video_path(video_path):
	video_player.stream = load(video_path)
	play_video()
	video_player.play()

func play_video():
	show_skip_key()
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	visible = true

func on_skip_bar_changed(val):
	var v = clamp(val, 0, skip_bar.max_value)
	if v <= 0:
		skip_container.visible = false
	else:
		skip_container.visible = true
	
	if v >= skip_bar.max_value:
		if video_player.is_playing():
			video_player.finished.emit()

func show_skip_key():
	skip_label.text = "[ " + OS.get_keycode_string(GameControlKeycode.current_key[GameControlKeycode.KEY.MENU]) + " ]"
