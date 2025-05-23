extends Node2D

enum attack_from {
	LEFT,
	RIGHT
}
var right_n_max = 4
var left_n_max = 4
var time_for_each
var flyer = preload("res://nodes/enemies/crowd.tscn")

var total_enemies = 0
var is_first_count = true
var max_enemies = 0
signal out_of_enemies

var parent

var attack_seq = [
	func():
		for i in range(0, left_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var flyer_inst = ReuseInitialize.initialize(GroupsName.CROWD, flyer)
				flyer_inst.position = get_index_of(flyer_inst, attack_from.RIGHT)
				if not flyer_inst.get_parent():
					parent.add_child(flyer_inst)
				check_is_dead(flyer_inst)
		,
	func():
		for i in range(0, right_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var flyer_inst = ReuseInitialize.initialize(GroupsName.CROWD, flyer)
				flyer_inst.position = get_index_of(flyer_inst)
				if not flyer_inst.get_parent():
					parent.add_child(flyer_inst)
				check_is_dead(flyer_inst)
		,
]

func _init(_parent):
	self.parent = _parent
	parent.stop_events.connect(stop)

func start():
	if attack_seq.size() > 0:
		var first_attack = attack_seq.pop_front()
		first_attack.call()
		if is_first_count:
			is_first_count = false
			max_enemies = total_enemies
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
	if total_enemies == 0 and is_stop():
		out_of_enemies.emit()

func check_is_dead(entity):
	if not entity.health.has_died.is_connected(decrease_total_enemies):
		entity.health.add_on_death(decrease_total_enemies)
	total_enemies += 1

func decrease_total_enemies():
	total_enemies -= 1
	is_all_dead()
