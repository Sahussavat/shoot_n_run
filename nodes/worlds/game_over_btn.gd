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
		ScoreControl.reset()
		player.visible = false
		PlayerDeathEffect.do_game_over_effect(player, player.global_position, func():
			process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().paused = true
			get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_in(func():
				var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
				menu.process_mode = Node.PROCESS_MODE_DISABLED
				visible = true
				, 0.5)
		)
	)

func retry():
	spawn_control.force_stop_all_events()
	floors_control.stop_loop()
	FloorsUtill.enable_load_floor()
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(reload_scene)

func reload_scene():
	get_tree().paused = false
	await get_tree().create_timer(0.1).timeout
	ChangePage.reload_current_scene()

func to_world():
	await get_tree().create_timer(0.1).timeout
	ChangePage.change_to_target_scene("res://nodes/worlds/main_menu.tscn")

func to_main_menu():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(to_world)
