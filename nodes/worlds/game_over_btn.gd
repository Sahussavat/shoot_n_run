extends PanelContainer

@onready var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
@onready var spawn_control = floors_control.spawn_control
@onready var retry_btn = $VBoxContainer/HBoxContainer/retry
@onready var main_menu_btn = $VBoxContainer/HBoxContainer/main_menu

func _ready():
	retry_btn.pressed.connect(retry)
	main_menu_btn.pressed.connect(to_main_menu)
	var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
	player.health.health.add_on_death(func():
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		visible = true
		var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
		menu.process_mode = Node.PROCESS_MODE_DISABLED
		)

func retry():
	get_tree().paused = false
	spawn_control.force_stop_all_events()
	floors_control.stop_loop()
	FloorsUtill.enable_load_floor()
	get_tree().reload_current_scene()

func to_world():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(to_main_menu)

func to_main_menu():
	ChangePage.change_to_target_scene("res://nodes/worlds/main_menu.tscn")
