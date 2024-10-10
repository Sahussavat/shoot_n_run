
var can_dash = true
var dash_cooldown

var player_body
var move_control

# Called when the node enters the scene tree for the first time.
func _init(_player_body, _move_control):
	self.player_body = _player_body
	self.move_control = _move_control
	dash_cooldown = Timer.new()
	dash_cooldown.wait_time = 1
	dash_cooldown.one_shot = true
	dash_cooldown.timeout.connect(reset_can_dash)
	player_body.add_child(dash_cooldown)

func dash(_delta):
	can_dash = false
	player_body.velocity.x = player_body.get_direction() * move_control.SPEED * 5
	player_body.set_anim("dash")
	dash_cooldown.start()

func dodge(delta):
	if can_dash:
		dash(delta)

func reset_can_dash():
	can_dash = true
