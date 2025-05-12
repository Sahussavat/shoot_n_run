extends Node2D

enum attack_from {
	UP1,
	UP2,
	DOWN1,
	DOWN2,
	LEFT1,
	LEFT2,
	RIGHT1,
	RIGHT2
}
var horizontal_n_max = 10
var vertical_n_max = 10
var time_for_each
var shark = preload("res://nodes/enemies/dash_enemy.tscn")

var total_enemies = 0
var is_first_count = true
var max_enemies = 0
signal out_of_enemies

var parent

var attack_seq = [
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.position = get_index_of(shark_inst, i)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.position = get_index_of(shark_inst, i, attack_from.LEFT2)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.do_mirror()
				shark_inst.position = get_index_of(shark_inst, i, attack_from.RIGHT1)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.do_mirror()
				shark_inst.position = get_index_of(shark_inst, i, attack_from.RIGHT2)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.rotate_by_degrees(90)
				shark_inst.position = get_index_of(shark_inst, i, attack_from.UP1)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.rotate_by_degrees(90)
				shark_inst.position = get_index_of(shark_inst, i, attack_from.UP2)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.rotate_by_degrees(-90)
				shark_inst.position = get_index_of(shark_inst, i, attack_from.DOWN1)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
		,
	func():
		for i in range(0, vertical_n_max):
			if not is_first_count and total_enemies < max_enemies * 2 or is_first_count:
				var shark_inst = ReuseInitialize.initialize(GroupsName.DASHER, shark)
				shark_inst.rotate_by_degrees(-90)
				shark_inst.position = get_index_of(shark_inst, i, attack_from.DOWN2)
				if not shark_inst.get_parent():
					parent.add_child(shark_inst)
				check_is_dead(shark_inst)
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
			max_enemies = total_enemies * 8
		do_wait()

func is_stop():
	return attack_seq.size() <= 0

func stop():
	attack_seq = []

func do_wait():
	time_for_each = parent.get_tree().create_timer(3, false)
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

func get_index_of(obj, index, direc = attack_from.LEFT1):
	var window_size = parent.get_viewport_rect().size
	var window_position = parent.get_viewport_rect().position
	var size_of_h_spawn = window_size.y / 2 / float(horizontal_n_max)
	var size_of_w_spawn = window_size.x / 2 / float(vertical_n_max)
	var center_len_h = size_of_h_spawn / 2.0
	var center_len_w = size_of_w_spawn / 2.0
	
	var x = window_position.x
	var y = window_position.y
	var padding = get_padding_spawn(obj)
	match direc:
		attack_from.UP1:
			y = y - padding.x
			x = size_of_w_spawn * index + center_len_w
		attack_from.UP2:
			y = y - padding.x
			x = window_size.x / 2 + size_of_w_spawn * index + center_len_w * 2
		attack_from.DOWN1:
			y = y + window_size.y + padding.x
			x = size_of_w_spawn * index + center_len_w
		attack_from.DOWN2:
			y = y + window_size.y + padding.x
			x = window_size.x / 2 + size_of_w_spawn * index + center_len_w * 2
		attack_from.LEFT1:
			x = x - padding.x
			y = size_of_h_spawn * index - center_len_h
		attack_from.LEFT2:
			x = x - padding.x
			y = window_size.y / 2 + size_of_h_spawn * index - center_len_h
		attack_from.RIGHT1:
			x = x + window_size.x + padding.x
			y = size_of_h_spawn * index - center_len_h
		attack_from.RIGHT2:
			x = x + window_size.x + padding.x
			y = window_size.y / 2 + size_of_h_spawn * index - center_len_h
	
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
