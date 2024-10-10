extends Node

const SPEED = 500.0
const JUMP_VELOCITY = -400.0

var player_body

var is_jumpped = false
var jump_count = 2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _init(_player_body):
	self.player_body = _player_body

func do_gravity(delta):
	if not player_body.is_on_floor():
		player_body.velocity.y += gravity * delta
	else:
		is_jumpped = false
		jump_count = 3
	
	if player_body.velocity.y > 0 and not player_body.is_on_floor():
		player_body.set_anim("jump_down")

func can_jump():
	return player_body.is_on_floor() or jump_count > 0

func update(delta):
	do_gravity(delta)
	if player_body.is_on_floor() and not is_jumpped:
		player_body.set_anim("run")

func jump():	
	player_body.velocity.y = JUMP_VELOCITY * 1.5
	is_jumpped = true
	player_body.set_anim("jump_up")
	jump_count = jump_count - 1

func move():
	player_body.velocity.x = player_body.get_direction() * SPEED

func idle():
	player_body.velocity.x = move_toward(player_body.velocity.x, 0, SPEED)



