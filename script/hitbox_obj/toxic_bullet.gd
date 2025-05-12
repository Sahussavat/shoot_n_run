extends StaticBody2D

var DEFAULT_MAX_SPEED = 35
var MAX_SPEED = DEFAULT_MAX_SPEED

var raycast = RayCast2D.new()
var target_pos
var direction
var destory_timer
var paused
var default_destroy_wait_time = 1
var destroy_wait_time = default_destroy_wait_time
var group_name = null

var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var danger_dash_zone_inst

@onready var hitbox = get_hitbox()
# Called when the node enters the scene tree for the first time.
func _ready():
	destory_timer = Timer.new()
	destory_timer.wait_time = destroy_wait_time
	destory_timer.one_shot = true
	destory_timer.autostart = true
	destory_timer.timeout.connect(destroy)
	add_child(destory_timer)
	hitbox.body_entered.connect(destroy_on_wall)
	
	raycast.set_collision_mask_value(1, false)
	raycast.set_collision_mask_value(3, true)
	add_child(raycast)

func _re_ready():
	BulletType.remove_to_all_type(self)
	set_color_by_type()
	destory_timer.timeout.disconnect(destroy)
	destory_timer.free()
	destory_timer = Timer.new()
	destory_timer.wait_time = destroy_wait_time
	destory_timer.one_shot = true
	destory_timer.autostart = true
	destory_timer.timeout.connect(destroy)
	add_child(destory_timer)
	
	raycast.free()
	raycast = RayCast2D.new()
	raycast.set_collision_mask_value(1, false)
	raycast.set_collision_mask_value(3, true)
	add_child(raycast)
	
	direction = null

func set_bullet_type(type):
	add_to_group(type)
	set_color_by_type(type)

func set_color_by_type(type = null):
	var colorrect = $ColorRect
	if type:
		var c = BulletType.get_bullet_type_color(type)
		colorrect.color = Color(c.x, c.y, c.z)
	else:
		colorrect.color = Color.WHITE


func get_hitbox():
	var children = get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if target_pos and not paused:
		if not direction:
			rotate_by_target()
			direction = (target_pos - position).normalized()
		var pos_move = position + (direction * pow(MAX_SPEED, 2) * _delta)
		destroy_on_wall_raycast_at(pos_move)
		position = pos_move

func destroy_on_wall(body):
	if body.get_collision_layer() == 3:
		destroy()

func destroy_on_wall_raycast_at(pos):
	raycast.target_position = to_local(pos)
	if raycast.get_collider():
		destroy()

func rotate_by_target():
	var degrees = global_position.direction_to(target_pos).angle()
	rotation = degrees

func pause_for_a_sec():
	destory_timer.set_paused(true)
	paused = true

func resume():
	destory_timer.set_paused(false)
	paused = false

func destroy():
	if not group_name:
		ReuseInitialize.to_reuse(GroupsName.BULLET, self)
	else:
		ReuseInitialize.to_reuse(group_name, self)
	MAX_SPEED = DEFAULT_MAX_SPEED
	destroy_wait_time = default_destroy_wait_time
	if is_instance_valid(danger_dash_zone_inst) and danger_dash_zone_inst:
		danger_dash_zone_inst.destroy()

func get_collision(parent):
	var children = parent.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
