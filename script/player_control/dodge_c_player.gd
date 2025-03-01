
var can_dash = true
var is_show_ghosting = false
var is_dashing = false
var dash_cooldown

var player_body
var move_control

var move_ghosting = preload("res://script/system_control/move_ghosting.gd")

# Called when the node enters the scene tree for the first time.
func _init(_player_body, _move_control):
	self.player_body = _player_body
	self.move_control = _move_control
	dash_cooldown = Timer.new()
	dash_cooldown.wait_time = 0.5
	dash_cooldown.one_shot = true
	dash_cooldown.timeout.connect(reset_can_dash)
	player_body.add_child(dash_cooldown)
	
	move_ghosting = move_ghosting.new(player_body)

func dash(_delta):
	can_dash = false
	is_dashing = true
	player_body.velocity.x = player_body.get_direction() * move_control.SPEED * 3
	player_body.set_anim("dash")
	dash_cooldown.start()

func dodge(delta):
	if can_dash:
		is_show_ghosting = true
		dash(delta)
	if is_show_ghosting:
		move_ghosting.create()

func reset_can_dash():
	can_dash = true
	is_dashing = false

func turn_off_ghosting():
	is_show_ghosting = false
