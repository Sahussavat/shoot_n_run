extends Node2D

enum attack_from {
	UP,
	DOWN,
	LEFT,
	RIGHT
}
var horizontal_n_max = 6
var vertical_n_max = 6
signal done_spawn
var time_for_each
var shark = preload("res://nodes/enemies/dash_enemy.tscn")

var total_enemies = 0
var is_first_count = true
var max_enemies = 0
signal out_of_enemies

var parent

var attack_seq = []

func _init(_parent):
	self.parent = _parent
	parent.stop_events.connect(stop)
	for i in range(0, vertical_n_max):
		attack_seq.append(func():
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.do_mirror()
				shark_inst.position = get_index_of(shark_inst, vertical_n_max - i - 1, attack_from.RIGHT)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
			)
	for i in range(0, vertical_n_max):
		attack_seq.append(func():
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.position = get_index_of(shark_inst, vertical_n_max - i - 1)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
			)

func start():
	if attack_seq.size() > 0:
		var first_attack = attack_seq.pop_front()
		first_attack.call()
		if is_first_count:
			is_first_count = false
			max_enemies = attack_seq.size()
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

func get_index_of(obj, index, direc = attack_from.LEFT):
	var window_size = parent.get_viewport_rect().size
	var window_position = parent.get_viewport_rect().position
	var size_of_h_spawn = window_size.y / float(horizontal_n_max)
	var size_of_w_spawn = window_size.x / float(vertical_n_max)
	var center_len_h = size_of_h_spawn / 2.0
	var center_len_w = size_of_w_spawn / 2.0
	
	var x = window_position.x
	var y = window_position.y
	var padding = get_padding_spawn(obj)
	match direc:
		attack_from.UP:
			y = y - padding.x
			x = size_of_w_spawn * index + center_len_w
		attack_from.DOWN:
			y = y + window_size.y + padding.x
			x = size_of_w_spawn * index + center_len_w
		attack_from.LEFT:
			x = x - padding.x
			y = size_of_h_spawn * index + center_len_h
		attack_from.RIGHT:
			x = x + window_size.x + padding.x
			y = size_of_h_spawn * index + center_len_h
	
	return Vector2(x, y)

func is_all_dead():
	if total_enemies <= 0 and is_stop():
		out_of_enemies.emit()

func check_is_dead(entity):
	if not entity.health.has_died.is_connected(decrease_total_enemies):
		entity.health.add_on_death(decrease_total_enemies)
	total_enemies += 1

func decrease_total_enemies():
	total_enemies -= 1
	is_all_dead()
