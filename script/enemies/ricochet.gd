extends CharacterBody2D

var dist_from_viewport = 10
var vel

# Called when the node enters the scene tree for the first time.
func _ready():
	vel = Vector2(1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var x = global_position.x
	var y = global_position.y
	if x > get_viewport_rect().size.x - dist_from_viewport:
		x = get_viewport_rect().size.x - dist_from_viewport + 1
		vel.x = abs(vel.x) * -1
	elif x < dist_from_viewport:
		x = dist_from_viewport - 1
		vel.x = abs(vel.x)
	
	if y > get_viewport_rect().size.y + dist_from_viewport:
		y = get_viewport_rect().size.y + dist_from_viewport + 1
		vel.y = abs(vel.y) * -1
	elif y < dist_from_viewport:
		y = dist_from_viewport - 1
		vel.y = abs(vel.y)
	
	global_position = Vector2(x, y) + vel * 5
