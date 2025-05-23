extends Control

var temp_menu_process_mode = PROCESS_MODE_INHERIT
var is_close_able = false

func _ready():
	Input.joy_connection_changed.connect(func(_device, _connected):
		show_list_movement()
		)
	if not is_in_group(GroupsName.TUTORIAL):
		add_to_group(GroupsName.TUTORIAL)
	
	show_list_movement()

func show_list_movement():
	var keys = {
		"move": get_key_name(GameControlKeycode.KEY.MOVE_LEFT) + ", " + get_key_name(GameControlKeycode.KEY.MOVE_RIGHT),
		"attack": get_key_name(GameControlKeycode.KEY.ATTACK),
		"jump": get_key_name(GameControlKeycode.KEY.JUMP),
		"dash": get_key_name(GameControlKeycode.KEY.DASH),
		"bullet_1": get_key_name(GameControlKeycode.KEY.BULLET_TYPE1),
		"bullet_2": get_key_name(GameControlKeycode.KEY.BULLET_TYPE2),
		"bullet_3": get_key_name(GameControlKeycode.KEY.BULLET_TYPE3),
	}
	
	for move_name in keys:
		var move = get_node("move_list/" + move_name)
		var k = move.get_node("key")
		k.text = keys[move_name]

func get_key_name(key):
	if JoyStickDetector.is_joy_connected():
		return GameControlKeycode.get_joy_string(GameControlKeycode.get_current_key()[key])
	return GameControlKeycode.get_key_string(GameControlKeycode.get_current_key()[key])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible and Input.is_anything_pressed() and is_close_able:
		hide_popup()

func show_popup():
	temp_menu_process_mode = get_tree().get_first_node_in_group(GroupsName.MENU).process_mode
	get_tree().get_first_node_in_group(GroupsName.MENU).process_mode = Node.PROCESS_MODE_DISABLED
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.05).timeout
	Engine.time_scale = 1
	get_tree().paused = true
	get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_in(func():
			visible = true
			await get_tree().create_timer(1).timeout
			is_close_able = true
			)

func hide_popup():
	visible = false
	get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_out(func():
			get_tree().paused = false
			get_tree().get_first_node_in_group(GroupsName.MENU).process_mode = temp_menu_process_mode
			slow_motion(0.05)
			)

func slow_motion(t = 0.1):
	Engine.time_scale = 0.1
	await get_tree().create_timer(t).timeout
	Engine.time_scale = 1
