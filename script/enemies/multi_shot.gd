extends Node

var parent
var toxic_bullet = preload("res://nodes/hitbox_objs/toxic_bullet.tscn")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var pause_shot = false
var is_shot_empty = false
signal shot_empty

# Called when the node enters the scene tree for the first time.
func _init(_parent):
	parent = _parent

func create_shots(n, wait_between, target):
	if n > 0 and is_instance_valid(parent) and not parent.health.is_dead() and not pause_shot:
		is_shot_empty = false
		parent.get_tree().create_timer(wait_between, false, false, true).timeout.connect(spawn_bullet.bind(n, wait_between, target));
	else:
		is_shot_empty = true
		shot_empty.emit()

func spawn_bullet(n, wait_between, target):
	var toxic_bullet_inst = ReuseInitialize.initialize(GroupsName.ENEMIES_BULLET, toxic_bullet)
	toxic_bullet_inst.group_name = GroupsName.ENEMIES_BULLET
	if is_instance_valid(parent):
		toxic_bullet_inst.global_position = parent.global_position
		toxic_bullet_inst.target_pos = target.global_position
		if not toxic_bullet_inst.get_parent():
			parent.get_parent().add_child(toxic_bullet_inst)
		if not toxic_bullet_inst.danger_dash_zone_inst:
			toxic_bullet_inst.danger_dash_zone_inst = danger_dash_zone.new(toxic_bullet_inst, get_collision(toxic_bullet_inst))
			toxic_bullet_inst.add_child(toxic_bullet_inst.danger_dash_zone_inst)
		var danger_dash_zone_inst = toxic_bullet_inst.danger_dash_zone_inst
		danger_dash_zone_inst.follow(target)
		danger_dash_zone_inst.start_cooldown(func():
			toxic_bullet_inst.resume()
			)
		toxic_bullet_inst.pause_for_a_sec()
		var hitbox = get_hitbox(toxic_bullet_inst)
		hitbox.set_collision_mask_value(1, true)
		hitbox.set_collision_mask_value(2, false)
		hitbox.set_collision_mask_value(3, false)
		
		create_shots(n - 1, wait_between, target)

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
