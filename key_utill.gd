extends Node

var just_press_check_arr = {}
var disabled_input_node_arr = []

func is_just_pressed(key_code):
	
	var is_pressed = (Input.is_physical_key_pressed(key_code) or Input.is_mouse_button_pressed(key_code) and key_code <= 3)
	var string_key_code = OS.get_keycode_string(key_code)
	if not just_press_check_arr.has(string_key_code):
		just_press_check_arr[string_key_code] = false

	if is_pressed and not just_press_check_arr[string_key_code]:
		just_press_check_arr[string_key_code] = true
		return true
	elif not is_pressed:
		just_press_check_arr[string_key_code] = false
	
	return false

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
