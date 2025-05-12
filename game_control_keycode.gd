extends Node

var save_control_path = "user://control.save"

const KEYBOARD = "keyboard"
const JOYPAD = "joypad"

enum KEY {
	ATTACK,
	JUMP,
	DASH,
	MOVE_RIGHT,
	MOVE_LEFT,
	MENU,
	BULLET_TYPE1,
	BULLET_TYPE2,
	BULLET_TYPE3,
}

var default_key_keyboard = {
	KEY.ATTACK: -MOUSE_BUTTON_LEFT - 1,
	KEY.JUMP: KEY_SPACE,
	KEY.DASH: KEY_SHIFT,
	KEY.MOVE_LEFT: KEY_A,
	KEY.MOVE_RIGHT: KEY_D,
	KEY.MENU: KEY_ESCAPE,
	KEY.BULLET_TYPE1: KEY_1,
	KEY.BULLET_TYPE2: KEY_2,
	KEY.BULLET_TYPE3: KEY_3,
}

var default_key_joypad = {
	KEY.ATTACK: JOY_BUTTON_RIGHT_STICK,
	KEY.JUMP: JOY_BUTTON_LEFT_SHOULDER,
	KEY.DASH: JOY_BUTTON_RIGHT_SHOULDER,
	KEY.MOVE_LEFT: JOY_BUTTON_DPAD_LEFT,
	KEY.MOVE_RIGHT: JOY_BUTTON_DPAD_RIGHT,
	KEY.MENU: JOY_BUTTON_B,
	KEY.BULLET_TYPE1: JOY_BUTTON_Y,
	KEY.BULLET_TYPE2: JOY_BUTTON_X,
	KEY.BULLET_TYPE3: JOY_BUTTON_A,
}

@onready var current_key = {
	KEYBOARD: default_key_keyboard.duplicate(),
	JOYPAD: default_key_joypad.duplicate(),
}

func get_current_key():
	if JoyStickDetector.is_joy_connected():
		return current_key[JOYPAD]
	else:
		return current_key[KEYBOARD]

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
		KEY.BULLET_TYPE1:
			return "Bullet Red"
		KEY.BULLET_TYPE2:
			return "Bullet Green"
		KEY.BULLET_TYPE3:
			return "Bullet Yellow"
		_:
			return "Whoops, forget to name this."

func change_keyboard_control_key(target_index, new_key):
	current_key[KEYBOARD][target_index] = new_key
	save_key_control()

func change_joypad_control_key(target_index, new_key):
	current_key[JOYPAD][target_index] = new_key
	save_key_control()

func change_control_to_default():
	current_key[KEYBOARD] = default_key_keyboard.duplicate()
	current_key[JOYPAD] = default_key_joypad.duplicate()
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
			for k in current_key[KEYBOARD]:
				current_key[KEYBOARD][k] = int(data[KEYBOARD][str(k)])
			for k in current_key[JOYPAD]:
				current_key[JOYPAD][k] = int(data[JOYPAD][str(k)])

func get_joy_string(keycode):
	if keycode < 0:
		var k = abs(keycode) - 1
		match  k:
			JOY_AXIS_TRIGGER_LEFT:
				return "L2"
			JOY_AXIS_TRIGGER_RIGHT:
				return "R2"
			_:
				return get_joy_string(JOY_BUTTON_LEFT_SHOULDER)
	else:
		match  keycode:
			JOY_BUTTON_LEFT_SHOULDER:
				return "L1"
			JOY_BUTTON_RIGHT_SHOULDER:
				return "R1"
			JOY_BUTTON_DPAD_LEFT:
				return "Pad Left"
			JOY_BUTTON_DPAD_RIGHT:
				return "Pad Right"
			JOY_BUTTON_DPAD_UP:
				return "Pad Up"
			JOY_BUTTON_DPAD_DOWN:
				return "Pad Down"
			JOY_BUTTON_A:
				return "A"
			JOY_BUTTON_B:
				return "B"
			JOY_BUTTON_X:
				return "X"
			JOY_BUTTON_Y:
				return "Y"
			JOY_BUTTON_LEFT_STICK:
				return "L3"
			JOY_BUTTON_RIGHT_STICK:
				return "R3"
			_:
				return get_joy_string(JOY_BUTTON_LEFT_SHOULDER)

func get_key_string(keycode):
	if keycode > 0:
		return OS.get_keycode_string(keycode)
	else:
		var k = abs(keycode) - 1
		match k:
			MOUSE_BUTTON_LEFT:
				return "Mouse Left"
			MOUSE_BUTTON_RIGHT:
				return "Mouse Right"
			MOUSE_BUTTON_MIDDLE:
				return "Mouse Middle"

func get_string(keycode):
	if JoyStickDetector.is_joy_connected():
		return get_joy_string(keycode)
	else:
		return get_key_string(keycode)
