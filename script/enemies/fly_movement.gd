extends Node2D

var SPEED = 20
var parent
var radius
var dist_from_viewport

var angle_direction = 1
var current_angle = 0
var change_direction_timer = 0
var charge_direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _init(_parent, _radius = 600, _dist_from_viewport = 5):
	self.parent = _parent
	self.radius = _radius
	self.dist_from_viewport = _dist_from_viewport

func move(target, delta):
	var target_pos = target
	if not (target is Vector2):
		target_pos = target.global_position
	parent.global_position = target_pos
	change_angle(delta)

func move_center(delta):
	move(get_circle_position(Vector2(parent.get_viewport_rect().size.x/2, parent.get_viewport_rect().size.y), current_angle), delta)
	
func get_circle_position(target, angle):
	var kill_circle_centre = target
	if not (target is Vector2):
		kill_circle_centre = target.global_position
	
	 #Distance from center to circumference of circle
	var x = kill_circle_centre.x + cos(angle * PI * 2) * radius;
	var y = kill_circle_centre.y + sin(angle * PI * 2) * radius;
	
	if x > parent.get_viewport_rect().size.x - dist_from_viewport:
		x = parent.get_viewport_rect().size.x - dist_from_viewport
	elif x < dist_from_viewport:
		x = dist_from_viewport
	
	if y > parent.get_viewport_rect().size.y + dist_from_viewport:
		y = parent.get_viewport_rect().size.y + dist_from_viewport
	elif y < dist_from_viewport:
		y = dist_from_viewport
		
	return Vector2(x, y)

func change_angle(delta):
	var inc = 0.0025 * angle_direction * delta * SPEED  * SlowMotionVal.slow_motion_val
	if current_angle >= 0.9 + inc:
		angle_direction = angle_direction * -1
		current_angle = 0.89
	elif current_angle <= 0.6:
		angle_direction = angle_direction * -1
		current_angle = 0.61
	else:
		current_angle = (current_angle + inc)
	
	if change_direction_timer <= 5:
		change_direction_timer += 0.1
	else:
		change_direction_timer = 0
		angle_direction = [1, -1][randi_range(0,1)]

func retret(delta, call_back = null):
	var center_pos = Vector2(parent.get_viewport_rect().size.x/2, parent.get_viewport_rect().size.y)
	var left_pos = get_circle_position(center_pos, 0.61)
	var right_pos = get_circle_position(center_pos, 0.89)
	if left_pos.distance_to(parent.global_position) <= right_pos.distance_to(parent.global_position):
		parent.global_position += parent.global_position.direction_to(left_pos) * SPEED * SPEED * delta  * SlowMotionVal.slow_motion_val  / 2
		if left_pos.distance_to(parent.global_position) <= SPEED * SPEED * delta  * SlowMotionVal.slow_motion_val  / 2:
			current_angle = 0.61
			if call_back:
				call_back.call()
	else:
		parent.global_position += parent.global_position.direction_to(right_pos) * SPEED * SPEED * delta  * SlowMotionVal.slow_motion_val / 2
		if right_pos.distance_to(parent.global_position) <= SPEED * SPEED * delta * SlowMotionVal.slow_motion_val  / 2:
			current_angle = 0.89
			if call_back:
				call_back.call()

func charge(delta, target_pos, call_back):
	if not charge_direction:
		charge_direction = parent.global_position.direction_to(target_pos)
	var charge_pos = parent.global_position + charge_direction * SPEED * SPEED * delta  * SlowMotionVal.slow_motion_val
	
	var x = charge_pos.x;
	var y = charge_pos.y;
	
	if x > parent.get_viewport_rect().size.x - dist_from_viewport:
		x = parent.get_viewport_rect().size.x - dist_from_viewport
		if call_back:
			call_back.call()
		charge_direction = null
	elif x < dist_from_viewport:
		x = dist_from_viewport
		if call_back:
			call_back.call()
		charge_direction = null
	if y > parent.get_viewport_rect().size.y + dist_from_viewport:
		y = parent.get_viewport_rect().size.y + dist_from_viewport
		if call_back:
			call_back.call()
		charge_direction = null
	elif y < dist_from_viewport:
		y = dist_from_viewport
		if call_back:
			call_back.call()
		charge_direction = null
	parent.global_position = Vector2(x, y)

func full_charge(delta, target_pos, call_back):
	if not charge_direction:
		charge_direction = parent.global_position.direction_to(target_pos)
	var charge_pos = parent.global_position + charge_direction * SPEED * SPEED * delta  * SlowMotionVal.slow_motion_val * 5
	
	var x = charge_pos.x;
	var y = charge_pos.y;
	
	if x > parent.get_viewport_rect().size.x + dist_from_viewport:
		if call_back:
			call_back.call()
		charge_direction = null
	elif x < dist_from_viewport:
		if call_back:
			call_back.call()
		charge_direction = null
	if y > parent.get_viewport_rect().size.y - dist_from_viewport:
		if call_back:
			call_back.call()
		charge_direction = null
	elif y < dist_from_viewport:
		if call_back:
			call_back.call()
		charge_direction = null
	parent.global_position = Vector2(x, y)
