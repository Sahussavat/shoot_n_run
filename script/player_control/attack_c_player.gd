
var player_body

var enable_shoot = false
var is_cooldown_shoot = false

var toxic_bullet = preload("res://nodes/hitbox_objs/toxic_bullet.tscn")

var shoot_cooldown

# Called when the node enters the scene tree for the first time.
func _init(_player_body):
	self.player_body = _player_body
	shoot_cooldown = Timer.new()
	shoot_cooldown.wait_time = 0.1
	shoot_cooldown.one_shot = true
	shoot_cooldown.timeout.connect(reset_is_cooldown_shoot)
	player_body.add_child(shoot_cooldown)

func update():
	if enable_shoot and not is_cooldown_shoot:
		is_cooldown_shoot = true
		spawn_toxic_bullet()
		shoot_cooldown.start()

func enable_attack():
	enable_shoot = not enable_shoot

func stop_attack():
	enable_shoot = false

func spawn_toxic_bullet():
	var toxic_bullet_inst = toxic_bullet.instantiate()
	toxic_bullet_inst.position = player_body.position
	toxic_bullet_inst.target_pos = player_body.get_global_mouse_position()
	player_body.get_parent().add_child(toxic_bullet_inst)

func reset_is_cooldown_shoot():
	is_cooldown_shoot = false
