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
	_animated_tree.update()
	
	match current_stat:
		stat.MOVE:
			move(delta)
		stat.DASH:
			dash(delta)
	
	move_and_slide()

func get_mouse_direction():
	return (get_global_mouse_position() - position).normalized().x

func get_direction():
	var is_left_press = int(Input.is_physical_key_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.MOVE_LEFT]))
	var is_right_press = int(Input.is_physical_key_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.MOVE_RIGHT]))
	
	return is_right_press - is_left_press

func to_move_stat():
	current_stat = stat.MOVE
	movement_c_player.idle()

func set_anim(anim_name):
	if _animated_state:
		_animated_state.travel(anim_name)

func move(delta):
	movement_c_player.update(delta)
	
	if key_utill.is_just_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.JUMP]) and movement_c_player.can_jump():
		movement_c_player.jump()
	# Handle jump.
	if get_direction():
		movement_c_player.move()
		if key_utill.is_just_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.DASH]):
			current_stat = stat.DASH
	else:
		movement_c_player.idle()
	
	if key_utill.is_just_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.ATTACK]):
		attack_c_player.enable_attack()
		AudioUtill.play_bgm("bgm_test")
	attack_c_player.update()
	

func stop_dash():
	to_move_stat()
	health.set_invicible(false)

func dash(delta):
	health.set_invicible(true)
	dodge_c_player.dodge(delta)

