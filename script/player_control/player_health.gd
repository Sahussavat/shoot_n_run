extends Node

var health = preload("res://script/system_control/health.gd")
var parent
var can_do_damage = true
var is_doing_invicible_effect = false

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
		var children2 = child.get_children()
		for child2 in children2:
			if child2 is CollisionShape2D:
				return child2
	return null

func enable_collision(enable = true):
	if collision:
		collision.set_deferred("disabled", not enable)
func heal(delta):
	health.set_health(delta)

func do_damage(damage):
	if can_do_damage and not health.is_invicible:
		can_do_damage = false
		enable_collision(can_do_damage)
		health.do_damage(damage)
		if not is_doing_invicible_effect:
			is_doing_invicible_effect = true
			set_invicible(true)
			parent.animation_player.play("hurt_frame")

func set_invicible(enable):
	if is_doing_invicible_effect:
		health.set_invicible(true)
	else:
		health.set_invicible(enable)

func reset_can_do_damage():
	is_doing_invicible_effect = false
	can_do_damage = true
	enable_collision()

func is_dead():
	return health.is_dead()

func get_sprite():
	var children = parent.get_children()
	for child in children:
		if child is Sprite2D:
			return child
	return null
