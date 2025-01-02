extends Node

var save_control_path = "user://control.save"

enum KEY {
	ATTACK,
	JUMP,
	DASH,
	MOVE_RIGHT,
	MOVE_LEFT,
	MENU,
}

var default_key = {
	KEY.ATTACK: MOUSE_BUTTON_LEFT,
	KEY.JUMP: KEY_SPACE,
	KEY.DASH: KEY_SHIFT,
	KEY.MOVE_LEFT: KEY_A,
	KEY.MOVE_RIGHT: KEY_D,
	KEY.MENU: KEY_ESCAPE,
}

var current_key = default_key.duplicate()

func get_key_name(key_index):
	match key_index:
		KEY.ATTACK:
			return "Attack"
		KEY.JUMP:
			return "Jump"
		KEY.DASH:
			return "Dash"
		KEY.MOVE_RIGHT:
			return "Move Right"
		KEY.MOVE_LEFT:
			return "Move Left"
		KEY.MENU:
			return "Menu"
		_:
			return "Whoops, forget to name this."

func change_control_key(target_index, new_key):
	current_key[target_index] = new_key
	save_key_control()

func change_control_to_default():
	current_key = default_key.duplicate()
	save_key_control()

func save_key_control():
	var control_save_file = FileAccess.open(save_control_path, FileAccess.WRITE)
	control_save_file.store_line(JSON.stringify(current_key))

func load_key_control():
	if FileAccess.file_exists(save_control_path):
		var control_save_file = FileAccess.open(save_control_path, FileAccess.READ)
		while control_save_file.get_position() < control_save_file.get_length():
			var json_string = control_save_file.get_line()

			# Creates the helper class to interact with JSON.
			var json = JSON.new()

			# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			
			var data = json.data
			for k in current_key:
				current_key[k] = int(data[str(k)])

func get_key_string(keycode):
	match keycode:
		MOUSE_BUTTON_LEFT:
			return "Mouse Left"
		MOUSE_BUTTON_RIGHT:
			return "Mouse Right"
		MOUSE_BUTTON_MIDDLE:
			return "Mouse Middle"
		_:
			return OS.get_keycode_string(keycode)
