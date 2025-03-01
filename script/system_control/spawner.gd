extends Node

var time_for_each

signal out_of_enemies

var total_enemies = 0
var parent

var attack_seq = []

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
	
func is_all_dead():
	if total_enemies <= 0 and is_stop():
		out_of_enemies.emit()

func check_is_dead(entity):
	entity.health.add_on_death(decrease_total_enemies)
	total_enemies += 1

func decrease_total_enemies():
	total_enemies -= 1
	is_all_dead()
