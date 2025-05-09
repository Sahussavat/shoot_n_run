extends Node

var just_press_check_arr = {}
var disabled_input_node_arr = []

func is_just_pressed(key_code):
	var k = key_code
	if k < 0:
		k = abs(key_code) - 1
	
	var is_pressed
	var string_key_code
	if JoyStickDetector.is_joy_connected():
		is_pressed = (Input.is_joy_button_pressed(0, k) or (Input.get_joy_axis(0, k)) and key_code < 0)
		string_key_code = GameControlKeycode.get_joy_string(k)
	else:
		is_pressed = (Input.is_physical_key_pressed(k) or (Input.is_mouse_button_pressed(k)) and key_code < 0)
		string_key_code = GameControlKeycode.get_key_string(k)
	if not just_press_check_arr.has(string_key_code):
		just_press_check_arr[string_key_code] = false

	if is_pressed and not just_press_check_arr[string_key_code]:
		just_press_check_arr[string_key_code] = true
		return true
	elif not is_pressed:
		just_press_check_arr[string_key_code] = false
	
	return false

func is_pressing(keycode):
	if JoyStickDetector.is_joy_connected():
		return Input.is_joy_button_pressed(0, keycode)
	else:
		return  Input.is_physical_key_pressed(keycode)

func get_pure_keycode(keycode):
	if keycode < 0:
		keycode = keycode * -1 - 1
	return keycode

func disable_all_input_node():
	var nodes = get_tree().get_nodes_in_group(GroupsName.INPUT_GROUP)
	for node in nodes:
		disabled_input_node_arr.append([node, node.process_mode])
		node.process_mode = Node.PROCESS_MODE_DISABLED

func undo_disable_all_input_node():
	for d in disabled_input_node_arr:
		d[0].process_mode = d[1]
	disabled_input_node_arr = []
