extends Node2D

enum attack_from {
	LEFT,
	RIGHT
}
var right_n_max = 4
var left_n_max = 4
var time_for_each
var flyer = preload("res://nodes/enemies/flyer.tscn")

signal out_of_enemies

var total_enemies = 0
var parent

var attack_seq = []

func _init(_parent):
	self.parent = _parent
	parent.stop_events.connect(stop)
	
	for i in range(0, left_n_max):
		attack_seq.append(func():
			var flyer_inst = flyer.instantiate()
			flyer_inst.position = get_index_of(flyer_inst)
			parent.add_child(flyer_inst)
			flyer_inst = flyer.instantiate()
			flyer_inst.position = get_index_of(flyer_inst, attack_from.RIGHT)
			parent.add_child(flyer_inst)
			check_is_dead(flyer_inst)
			)

func start():
	if attack_seq.size() > 0:
		var first_attack = attack_seq.pop_front()
		first_attack.call()
		do_wait()

func is_stop():
	return attack_seq.size() <= 0

func stop():
	attack_seq = []

func do_wait():
	time_for_each = parent.get_tree().create_timer(1, false)
	time_for_each.timeout.connect(start)

func get_collision(obj):
	var children = obj.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null

func get_padding_spawn(obj):
	var collision = get_collision(obj)
	if collision:
		return Vector2(collision.shape.size.x,	collision.shape.size.y)
	return Vector2(380, 380)

func get_index_of(obj, direc = attack_from.LEFT):
	var window_size = parent.get_viewport_rect().size
	
	var win_size_1_4_x = window_size.x / 4.0
	var padding = get_padding_spawn(obj)
	var y =  -padding.y
	var x = 0
	match direc:
		attack_from.LEFT:
			x = win_size_1_4_x
		attack_from.RIGHT:
			x = win_size_1_4_x * 3
	return Vector2(x, y)
	
func is_all_dead():
	if total_enemies <= 0 and is_stop():
		out_of_enemies.emit()

func check_is_dead(entity):
	entity.health.add_on_death(decrease_total_enemies)
	total_enemies += 1

func decrease_total_enemies():
	total_enemies -= 1
	is_all_dead()
