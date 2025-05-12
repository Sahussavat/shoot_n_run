extends Node

var parent
var dist_from_viewport = 10
var vel

# Called when the node enters the scene tree for the first time.
func _init(_parent, _dist_from_viewport = 10):
	parent = _parent
	dist_from_viewport = _dist_from_viewport
	var r = [-1,1]
	vel = Vector2(r[randi_range(0, 1)],r[randi_range(0, 1)])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func move(delta):
	var x = parent.global_position.x
	var y = parent.global_position.y
	if x > parent.get_viewport_rect().size.x - dist_from_viewport:
		x = parent.get_viewport_rect().size.x - dist_from_viewport + 1
		vel.x = abs(vel.x) * -1
	elif x < dist_from_viewport:
		x = dist_from_viewport - 1
		vel.x = abs(vel.x)
	
	if y > parent.get_viewport_rect().size.y + dist_from_viewport:
		y = parent.get_viewport_rect().size.y + dist_from_viewport + 1
		vel.y = abs(vel.y) * -1
	elif y < dist_from_viewport:
		y = dist_from_viewport - 1
		vel.y = abs(vel.y)
	
	parent.global_position = Vector2(x, y) + vel * pow(5, 2) * delta * 10

