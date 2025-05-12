extends Node


var max_health
var health
var is_invicible = false
var is_died = false
var custom_hit_conditions = []
signal has_died 
signal change_health

# Called when the node enters the scene tree for the first time.
func _init(_health):
	self.health = _health
	max_health = health
	check_death()

func do_damage(damage, damage_obj = null):
	if not is_invicible and check_can_hit(damage_obj):
		set_health(-damage)

func add_hit_condition(fn):
	custom_hit_conditions.push_front(fn)

func check_can_hit(damage_obj):
	if damage_obj:
		for con in custom_hit_conditions:
			if not con.call(damage_obj):
				return false
	return true

func add_on_death(call_back):
	has_died.connect(func():
		if is_dead():
			call_back.call()
		)

func is_dead():
	return health <= 0

func set_invicible(enable):
	is_invicible = enable

func set_health(delta): 
	health = clamp(health + delta, 0, max_health)
	change_health.emit()
	check_death()

func check_death():
	if is_dead() and not is_died:
		is_died = true
		has_died.emit()
	elif not is_dead():
		is_died = false

func revive():
	is_died = false 
	health = max_health
