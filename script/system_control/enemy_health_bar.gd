extends Node

var health_bar_control = preload("res://script/system_control/health_bar.gd")
var sprite
var parent
var hide_bar_timer = Timer.new()
var health_bar = ProgressBar.new()
var is_hit_flashing = false

# Called when the node enters the scene tree for the first time.
func _init(_parent, health):
	parent = _parent 
	health_bar.show_percentage = false
	health_bar.value = health_bar.max_value
	health_bar.size.x = get_collision(parent).shape.size.x
	health_bar.size.y = health_bar.size.y * 2
	health_bar.set_visible(false)
	parent.add_child(health_bar)
	health_bar_control = health_bar_control.new(health_bar, health)
	
	hide_bar_timer.wait_time = 1
	hide_bar_timer.one_shot = true
	hide_bar_timer.timeout.connect(func():
		enable_health_bar(false)
		)
	parent.add_child(hide_bar_timer)
	health.change_health.connect(func():
		if not health.is_died:
			health_bar.set_visible(true)
			hide_bar_timer.start()
		else:
			hide_bar_timer.stop()
			health_bar.set_visible(false)
	)

func set_position_bar(x,y):
	health_bar.position = Vector2(x,y)
	
func set_size_bar(x,y):
	health_bar.size = Vector2(x,y)

func get_collision(obj):
	var children = obj.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null

func enable_health_bar(enable = true):
	health_bar.set_visible(enable)

func reset_bar():
	health_bar_control.update_bar()
	hide_bar_timer.stop()
	health_bar.set_visible(false)


