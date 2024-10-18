extends Node

var health = preload("res://script/system_control/health.gd")
var parent
var can_do_damage = true

var collision
var wait_for_damage_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _init(_parent, _max_health):
	self.parent = _parent
	health = health.new(_max_health)
	wait_for_damage_timer.wait_time = 0.5
	wait_for_damage_timer.one_shot = true
	wait_for_damage_timer.timeout.connect(reset_can_do_damage)
	parent.add_child(wait_for_damage_timer)
	collision = get_collision(parent)

func get_collision(obj):
	var children = obj.get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

func enable_collision(enable = true):
	if collision:
		collision.set_deferred("monitorable", enable)

func do_damage(damage):
	if can_do_damage:
		can_do_damage = false
		enable_collision(can_do_damage)
		health.do_damage(damage)
		wait_for_damage_timer.start()

func set_invicible(enable):
	health.set_invicible(enable)

func reset_can_do_damage():
	can_do_damage = true
	enable_collision()
