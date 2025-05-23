extends CharacterBody2D

enum stat {
	MOVE,
	DASH
}
var current_stat = stat.MOVE

@onready var key_utill = KeyUtill

@onready var attack_c_player = preload("res://script/player_control/attack_c_player.gd")
@onready var dodge_c_player = preload("res://script/player_control/dodge_c_player.gd")
@onready var movement_c_player = preload("res://script/player_control/movement_c_player.gd")
@onready var coin_c_player = preload("res://script/player_control/coin_c_player.gd")
@onready var health = preload("res://script/player_control/player_health.gd")
@onready var _animated_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var _animated_state = _animated_tree.get("parameters/playback")

func _ready():
	if not is_in_group(GroupsName.PLAYER):
		add_to_group(GroupsName.PLAYER)
	if not is_in_group(GroupsName.INPUT_GROUP):
		add_to_group(GroupsName.INPUT_GROUP)
	attack_c_player = attack_c_player.new(self)
	movement_c_player = movement_c_player.new(self)
	dodge_c_player = dodge_c_player.new(self, movement_c_player)
	coin_c_player = coin_c_player.new(self)
	health = health.new(self, 100)

func _physics_process(delta):
	if not health.is_dead():
		_animated_tree.update()
		
		match current_stat:
			stat.MOVE:
				move(delta)
			stat.DASH:
				dash(delta)
		
		move_and_slide()

func get_mouse_direction():
	if JoyStickDetector.is_joy_connected():
		var target_post = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if ceil(10 * Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))/100 == 0 and ceil(10 * Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))/100 == 0:
			target_post = 3 * Vector2(1, -1)
		return (2 * target_post).x
	return (get_global_mouse_position() - global_position).normalized().x

func get_direction():
	var is_left_press = int( KeyUtill.is_pressing(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.MOVE_LEFT]))
	var is_right_press = int(KeyUtill.is_pressing(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.MOVE_RIGHT]))
	return is_right_press - is_left_press

func to_move_stat():
	current_stat = stat.MOVE
	movement_c_player.idle()

func set_anim(anim_name):
	if _animated_state:
		_animated_state.travel(anim_name)

func move(delta):
	movement_c_player.update(delta)
	if key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.JUMP]) and movement_c_player.can_jump():
		movement_c_player.jump()
		
	# Handle jump.
	if get_direction():
		movement_c_player.move()
		if key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.DASH]):
			current_stat = stat.DASH
	else:
		movement_c_player.idle()
	
	if key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.ATTACK]):
		attack_c_player.enable_attack()
		AudioUtill.play_bgm("bgm_test")
	attack_c_player.update()
	
	if key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.BULLET_TYPE1]):
		attack_c_player.set_attack_bullet_type(BulletType.RED)
	elif key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.BULLET_TYPE2]):
		attack_c_player.set_attack_bullet_type(BulletType.GREEN)
	elif key_utill.is_just_pressed(GameControlKeycode.get_current_key()[GameControlKeycode.KEY.BULLET_TYPE3]):
		attack_c_player.set_attack_bullet_type(BulletType.YELLOW)
	

func stop_dash():
	dodge_c_player.is_dashing = false
	to_move_stat()
	dodge_c_player.turn_off_ghosting()
	health.set_invicible(false)

func stop_hurt_frame():
	health.reset_can_do_damage()
	if not dodge_c_player.is_dashing:
		health.set_invicible(false)

func dash(delta):
	health.set_invicible(true)
	dodge_c_player.dodge(delta)

