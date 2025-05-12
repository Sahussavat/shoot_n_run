
var player_body

var enable_shoot = false
var is_cooldown_shoot = false
var attack_bullet_type = BulletType.RED

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
	if enable_shoot and not is_cooldown_shoot and not player_body.health.is_dead():
		is_cooldown_shoot = true
		spawn_toxic_bullet()
		shoot_cooldown.start()

func enable_attack():
	enable_shoot = not enable_shoot

func stop_attack():
	enable_shoot = false

func spawn_toxic_bullet():
	var toxic_bullet_inst = ReuseInitialize.initialize(GroupsName.BULLET, toxic_bullet)
	toxic_bullet_inst.set_bullet_type(attack_bullet_type)
	toxic_bullet_inst.position = player_body.position
	if JoyStickDetector.is_joy_connected():
		var target_post = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) == 0 and Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) == 0:
			target_post = Vector2(1, -1)
		toxic_bullet_inst.target_pos = player_body.global_position + 2 * target_post
	else:
		toxic_bullet_inst.target_pos = player_body.get_global_mouse_position()
	var area2d = get_area2d(toxic_bullet_inst)
	if not area2d.entity_death.is_connected(heal_on_kill):
		area2d.entity_death.connect(heal_on_kill)
	if not toxic_bullet_inst.get_parent():
		player_body.get_parent().add_child(toxic_bullet_inst)

func heal_on_kill(enemy):
	if enemy.is_in_group(GroupsName.ENEMIES) and not player_body.health.is_dead():
		player_body.health.heal(player_body.health.health.max_health * 0.01)

func reset_is_cooldown_shoot():
	is_cooldown_shoot = false

func get_area2d(obj):
	var children = obj.get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

func set_attack_bullet_type(type):
	attack_bullet_type = type
