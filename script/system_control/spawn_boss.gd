extends Node2D

enum attack_from {
	LEFT,
	RIGHT
}
var time_for_each
var boss_fly = preload("res://nodes/enemies/boss_fly.tscn")

var total_enemies = 0
var is_first_count = true
var max_enemies = 0
signal out_of_enemies

var parent

var attack_seq = [
	func():
		var boss_inst = boss_fly.instantiate()
		boss_inst.disable_minigame = true
		parent.add_child(boss_inst)
		boss_inst.health.has_died.connect(parent.get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL).boss_dead)
		boss_inst.spawn(Vector2(parent.get_viewport_rect().size.x, parent.get_viewport_rect().size.y / -2))
		check_is_dead(boss_inst)
]

func _init(_parent):
	self.parent = _parent
	parent.stop_events.connect(stop)

func start():
	if attack_seq.size() > 0:
		var first_attack = attack_seq.pop_front()
		if not is_first_count and total_enemies < max_enemies * 2:
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
	
func is_all_dead():
	if total_enemies == 0 and is_stop():
		out_of_enemies.emit()

func check_is_dead(entity):
	entity.health.add_on_death(decrease_total_enemies)
	total_enemies += 1

func decrease_total_enemies():
	total_enemies -= 1
	is_all_dead()
