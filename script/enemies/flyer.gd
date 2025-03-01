extends CharacterBody2D

enum state {
	MOVE,
	MOVE_AND_AIM,
	RETREAT
}

var current_state = state.RETREAT

var SPEED = 800

var max_health = 100

var timer
var danger_dash_zone_inst

var health = preload("res://script/system_control/health.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
var fly_movement = preload("res://script/enemies/fly_movement.gd")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var toxic_bullet = preload("res://nodes/hitbox_objs/toxic_bullet.tscn")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var wait_for_attack = Timer.new()
@onready var collision = get_collision(self)

func _ready():
	print("yoqwwwwwwww")
	health = health.new(max_health)
	health.add_on_death(destroy)
	health_bar_control.new(self, health)
	wait_for_attack.wait_time = 5
	wait_for_attack.one_shot = true
	wait_for_attack.timeout.connect(reset_atk)
	add_child(wait_for_attack)
	fly_movement = fly_movement.new(self)

var angle = 0.1
var direction = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	match current_state:
		state.MOVE:
			if wait_for_attack.is_stopped():
				wait_for_attack.start()
			fly_movement.move_center()
		state.MOVE_AND_AIM:
			if not danger_dash_zone_inst:
				danger_dash_zone_inst = danger_dash_zone.new(self, collision)
				danger_dash_zone_inst.start_cooldown(func():
					var toxic_bullet_inst = toxic_bullet.instantiate()
					toxic_bullet_inst.position = global_position
					toxic_bullet_inst.target_pos = player.global_position
					get_parent().add_child(toxic_bullet_inst)
					var hitbox = get_hitbox(toxic_bullet_inst)
					hitbox.set_collision_mask_value(1, true)
					hitbox.set_collision_mask_value(2, false)
					hitbox.set_collision_mask_value(3, false)
					
					current_state = state.MOVE
					)
			else:
				danger_dash_zone_inst.follow(player)
			fly_movement.move_center()
		state.RETREAT:
			fly_movement.retret(func():
				current_state = state.MOVE
				)

func get_hitbox(parent):
	var children = parent.get_children()
	for child in children:
		if child is Area2D:
			return child
	return null

func get_collision(parent):
	var children = parent.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null

func reset_atk():
	current_state = state.MOVE_AND_AIM
		
func destroy():
	queue_free()

