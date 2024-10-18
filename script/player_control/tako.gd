extends CharacterBody2D

enum stat {
	MOVE,
	DASH
}
var current_stat = stat.MOVE

var just_press_check_arr = {}

@onready var attack_c_player = preload("res://script/player_control/attack_c_player.gd")
@onready var dodge_c_player = preload("res://script/player_control/dodge_c_player.gd")
@onready var movement_c_player = preload("res://script/player_control/movement_c_player.gd")
@onready var coin_c_player = preload("res://script/player_control/coin_c_player.gd")
@onready var health = preload("res://script/player_control/player_health.gd")
@onready var _animated_tree = $AnimationTree
@onready var _animated_state = _animated_tree.get("parameters/playback")

func _ready():
	if not is_in_group(GroupsName.PLAYER):
		add_to_group(GroupsName.PLAYER)
	attack_c_player = attack_c_player.new(self)
	movement_c_player = movement_c_player.new(self)
	dodge_c_player = dodge_c_player.new(self, movement_c_player)
	coin_c_player = coin_c_player.new(self)
	health = health.new(self, 100)

func _physics_process(delta):
	_animated_tree.update()
	
	match current_stat:
		stat.MOVE:
			move(delta)
		stat.DASH:
			dash(delta)
	
	move_and_slide()

func is_just_pressed(key_code):
	var is_pressed = (Input.is_physical_key_pressed(key_code) or Input.is_mouse_button_pressed(key_code))
	var string_key_code = OS.get_keycode_string(key_code)
	if not just_press_check_arr.has(string_key_code):
		just_press_check_arr[string_key_code] = false

	if is_pressed and not just_press_check_arr[string_key_code]:
		just_press_check_arr[string_key_code] = true
		return true
	elif not is_pressed:
		just_press_check_arr[string_key_code] = false
	
	return false

		

func get_mouse_direction():
	return (get_global_mouse_position() - position).normalized().x

func get_direction():
	var is_left_press = int(Input.is_physical_key_pressed(KEY_A))
	var is_right_press = int(Input.is_physical_key_pressed(KEY_D))
	
	return is_right_press - is_left_press

func to_move_stat():
	current_stat = stat.MOVE
	movement_c_player.idle()

func set_anim(anim_name):
	if _animated_state:
		_animated_state.travel(anim_name)

func move(delta):
	movement_c_player.update(delta)
	
	if is_just_pressed(KEY_SPACE) and movement_c_player.can_jump():
		movement_c_player.jump()
	# Handle jump.
	if get_direction():
		movement_c_player.move()
		if is_just_pressed(KEY_SHIFT):
			current_stat = stat.DASH
	else:
		movement_c_player.idle()
	
	if is_just_pressed(MOUSE_BUTTON_LEFT):
		attack_c_player.enable_attack()
	attack_c_player.update()
	

func stop_dash():
	to_move_stat()
	health.set_invicible(false)

func dash(delta):
	health.set_invicible(true)
	dodge_c_player.dodge(delta)

