extends Node

const JOY_LEFT_MOVE = "joy_left_move"
const JOY_RIGHT_MOVE = "joy_right_move"

@onready var controls = $ScrollContainer/controls
@onready var default_btn = $default_btn
var selected_key
var selected_key_btn : Button
var done_bind_key = false

func _ready():
	GameControlKeycode.load_key_control()
	load_key_ui()
	default_btn.pressed.connect(func():
		GameControlKeycode.change_control_to_default()
		reload_key_ui()
		)

func reload_key_ui():
	for c in controls.get_children():
		c.queue_free()
	load_key_ui()

func load_key_ui():
	var current_key = GameControlKeycode.current_key
	var tab = controls.get_parent().get_parent()
	var first_change_btn
	var prev_change_btn
	
	controls.add_child(Label.new())
	var txt = Label.new()
	txt.text = "Keyboard and Mouse"
	controls.add_child(txt)
	for key in current_key[GameControlKeycode.KEYBOARD]:
		var label_name = Label.new()
		label_name.text = GameControlKeycode.get_key_name(key)
		var change_btn = Button.new()
		change_btn.text = GameControlKeycode.get_key_string(current_key[GameControlKeycode.KEYBOARD][key])
		controls.add_child(label_name)
		controls.add_child(change_btn)
		if prev_change_btn:
			prev_change_btn.focus_neighbor_bottom = change_btn.get_path()
		if not first_change_btn:
			first_change_btn = change_btn
		change_btn.pressed.connect(func():
			on_click_change_btn(change_btn, key)
			)
		prev_change_btn = change_btn
	
	controls.add_child(Label.new())
	txt = Label.new()
	txt.text = "Gamepad"
	controls.add_child(txt)
	
	for key in current_key[GameControlKeycode.JOYPAD]:
		var label_name = Label.new()
		label_name.text = GameControlKeycode.get_key_name(key)
		var change_btn = Button.new()
		change_btn.text = GameControlKeycode.get_joy_string(current_key[GameControlKeycode.JOYPAD][key])
		controls.add_child(label_name)
		controls.add_child(change_btn)
		if prev_change_btn:
			prev_change_btn.focus_neighbor_bottom = change_btn.get_path()
		if not first_change_btn:
			first_change_btn = change_btn
		change_btn.pressed.connect(func():
			on_click_change_btn(change_btn, key)
			)
		prev_change_btn = change_btn
	
	prev_change_btn.focus_neighbor_bottom = default_btn.get_path()
	first_change_btn.focus_neighbor_top = tab.get_path()
	tab.focus_neighbor_bottom = tab.get_path_to(first_change_btn)

func on_click_change_btn(change_btn, key):
	if not selected_key_btn:
		KeyUtill.disable_all_input_node()
		selected_key = key
		selected_key_btn = change_btn
		selected_key_btn.disabled = true

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion) \
		 and just_pressed and selected_key_btn and selected_key != null:
		
		var keycode
		if event is InputEventKey:
			keycode = event.physical_keycode
		elif event is InputEventMouseButton or event is InputEventJoypadButton:
			keycode = event.button_index
		elif event is InputEventJoypadMotion:
			keycode = event.axis
		
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event is InputEventJoypadMotion:
				keycode = -(keycode + 1)
			GameControlKeycode.change_joypad_control_key(selected_key, keycode)
			selected_key_btn.text = GameControlKeycode.get_joy_string(keycode)
		elif event is InputEventMouseButton or event is InputEventKey:
			if event is InputEventMouseButton:
				keycode = -(keycode + 1)
			GameControlKeycode.change_keyboard_control_key(selected_key, keycode)
			selected_key_btn.text = GameControlKeycode.get_key_string(keycode)
		
		selected_key = null
		await get_tree().create_timer(0.5, true).timeout
		selected_key_btn.disabled = false
		selected_key_btn = null
		KeyUtill.undo_disable_all_input_node()
