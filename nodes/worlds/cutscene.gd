extends Control

@onready var video_player = $cutscene
@onready var skip_container = $skip_container
var temp_menu_process_mode = PROCESS_MODE_INHERIT
var run_other_cutscene_fn

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.CUTSCENE)
	video_player.add_to_group(GroupsName.VIDEO)
	AudioUtill.set_video_volume_scale()
	video_player.finished.connect(on_finished)
	process_mode = Node.PROCESS_MODE_ALWAYS
	if get_tree().get_first_node_in_group(GroupsName.MENU):
		temp_menu_process_mode = get_tree().get_first_node_in_group(GroupsName.MENU).process_mode
	if video_player.autoplay:
		play_video()
	
	skip_container.on_finished_skip.connect(func():
		video_player.finished.emit()
		)

func on_finished():
	skip_container.enable_skip = false
	skip_container.reset_skip_bar()
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(func():
		if run_other_cutscene_fn:
			run_other_cutscene_fn.call()
			run_other_cutscene_fn = null
		else:
			get_tree().paused = false
			visible = false
			get_tree().get_first_node_in_group(GroupsName.MENU).process_mode = temp_menu_process_mode
			get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_out()
		video_player.stop()
			)

func play_video_path(video_path):
	video_player.stream = load(video_path)
	play_video()

func play_video():
	get_tree().get_first_node_in_group(GroupsName.MENU).process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	visible = true
	video_player.play()
	skip_container.enable_skip = true
