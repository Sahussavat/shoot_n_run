extends Node

var parent
var toxic_bullet = preload("res://nodes/hitbox_objs/toxic_bullet.tscn")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var is_shot_empty = false
var i = 0

# Called when the node enters the scene tree for the first time.
func _init(_parent):
	parent = _parent

func create_shots(n, wait_between = 0):
	if n > 0 and i < n and is_instance_valid(parent):
		is_shot_empty = false
		var toxic_bullet_inst = ReuseInitialize.initialize(GroupsName.ENEMIES_BULLET, toxic_bullet)
		toxic_bullet_inst.group_name = GroupsName.ENEMIES_BULLET
		toxic_bullet_inst.global_position = parent.global_position
		var centre = toxic_bullet_inst.global_position
		var x = centre.x + cos(float(i)/n * PI * 2) * 5;
		var y = centre.y + sin(float(i)/n * PI * 2) * 5;
		toxic_bullet_inst.target_pos = Vector2(x, y)
		toxic_bullet_inst.MAX_SPEED = 35
		toxic_bullet_inst.destroy_wait_time = 50
		if not toxic_bullet_inst.get_parent():
			parent.get_parent().add_child(toxic_bullet_inst)
		var hitbox = get_hitbox(toxic_bullet_inst)
		hitbox.set_collision_mask_value(1, true)
		hitbox.set_collision_mask_value(2, false)
		hitbox.set_collision_mask_value(3, false)
		i += 1
		create_shots(n, wait_between)
	else:
		i = 0
		is_shot_empty = true
		
func get_hitbox(p):
	var children = p.get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

func get_collision(p):
	var children = p.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
