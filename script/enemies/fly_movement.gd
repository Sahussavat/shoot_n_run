extends Node2D

var parent
var radius
var dist_from_viewport


var angle_direction = 1
var current_angle = 0
var change_direction_timer = 0
var target_lock_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _init(_parent, _radius = 600, _dist_from_viewport = 5):
	self.parent = _parent
	self.radius = _radius
	self.dist_from_viewport = _dist_from_viewport

func move(target):
	var target_pos = target
	if not (target is Vector2):
		target_pos = target.global_position
	parent.global_position = target_pos
	change_angle()

func move_center():
	move(get_circle_position(Vector2(parent.get_viewport_rect().size.x/2, parent.get_viewport_rect().size.y), current_angle ))
	
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

func change_angle():
	var inc = 0.0025 * angle_direction
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

