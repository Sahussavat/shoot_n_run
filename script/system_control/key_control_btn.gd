extends Node

@onready var controls = $ScrollContainer/controls
@onready var default_btn = $default_btn
var selected_key
var selected_key_btn : Button

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
	for key in current_key:
		var label_name = Label.new()
		label_name.text = GameControlKeycode.get_key_name(key)
		var change_btn = Button.new()
		change_btn.focus_mode = Control.FOCUS_NONE
		change_btn.text = GameControlKeycode.get_key_string(GameControlKeycode.current_key[key])
		controls.add_child(label_name)
		controls.add_child(change_btn)
		change_btn.pressed.connect(func():
			KeyUtill.disable_all_input_node()
			selected_key = key
			selected_key_btn = change_btn
			)

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if (event is InputEventKey or event is InputEventMouseButton) and just_pressed and selected_key_btn and selected_key != null:
		var keycode
		if event is InputEventKey:
			keycode = event.physical_keycode
		elif event is InputEventMouseButton:
			keycode = event.button_index
		GameControlKeycode.change_control_key(selected_key, keycode)
		selected_key_btn.text = GameControlKeycode.get_key_string(keycode)
		selected_key = null
		selected_key_btn = null
		await get_tree().create_timer(0.5, true).timeout
		KeyUtill.undo_disable_all_input_node()
