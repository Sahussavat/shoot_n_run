extends CharacterBody2D

enum state {
	MOVE,
	AIM,
	FULL_CHARGE
}

var current_state = state.MOVE

var MAX_SPEED = 50
var SEPERATION_RADIUS = 150
var MAX_SEPRATION = 4

var aiming = false
var max_health = 25
var crowd_group
var max_velocity = 10
var danger_dash_zone_inst
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health = preload("res://script/system_control/health.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var fly_movement = preload("res://script/enemies/fly_movement.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var wait_for_self_bullet = Timer.new()
@onready var collision = get_collision(self)
@onready var barrier = $outline

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.ENEMIES)
	health = health.new(max_health)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.add_on_death(destroy)
	health_bar_control = health_bar_control.new(self, health)
	add_to_group(GroupsName.CROWD)
	EntitiesGroup.add_entity_to_group(GroupsName.CROWD, self)
	crowd_group = EntitiesGroup.groups[GroupsName.CROWD]
	wait_for_self_bullet.wait_time = 10
	wait_for_self_bullet.one_shot = true
	wait_for_self_bullet.timeout.connect(to_full_charge)
	add_child(wait_for_self_bullet)
	fly_movement = fly_movement.new(self)
	barrier.init_barrier(self)
	barrier.start_random_barrier()

func _re_ready():
	health.revive()
	health_bar_control.reset_bar()
	current_state = state.MOVE
	barrier.start_random_barrier()
	wait_for_self_bullet.free()
	wait_for_self_bullet = Timer.new()
	wait_for_self_bullet.wait_time = 10
	wait_for_self_bullet.one_shot = true
	wait_for_self_bullet.timeout.connect(to_full_charge)
	add_child(wait_for_self_bullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match current_state:
		state.MOVE:
			if wait_for_self_bullet.is_stopped():
				wait_for_self_bullet.start()
			if global_position.distance_to(player.global_position) > 10:
				global_position += seek(player.global_position) + seperation() * 0.5 + velocity * pow(MAX_SPEED, 2) * _delta  * SlowMotionVal.slow_motion_val
		state.AIM:
			if not aiming:
				aiming = true
				danger_dash_zone_init(func():
					current_state = state.FULL_CHARGE
					aiming = false
				)
			else:
				danger_dash_zone_inst.follow(player)
		state.FULL_CHARGE:
			fly_movement.full_charge(_delta, player.global_position, func():
				destroy(true)
				)

func seek(target_pos):
	var desired_velocity = (target_pos - global_position).normalized() * max_velocity
	var steering = desired_velocity - velocity
	return steering

func seperation():
	var force =  Vector2.ZERO
	var neighborCount = 0
	
	for c in crowd_group:
		if is_instance_valid(c):
			if c != self and global_position.distance_to(c.global_position) <= SEPERATION_RADIUS:
				force += c.global_position - global_position
				neighborCount = neighborCount + 1
	
	if neighborCount != 0:
		force /= neighborCount
		force *= -1
	
	force = force.normalized()
	force *= MAX_SEPRATION
	
	return force

func get_collision(parent):
	var children = parent.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null

func stop_countdown():
	wait_for_self_bullet.stop()
	if is_instance_valid(danger_dash_zone_inst) and danger_dash_zone_inst:
		danger_dash_zone_inst.destroy()

func danger_dash_zone_init(call_back):
	if not danger_dash_zone_inst:
		danger_dash_zone_inst = danger_dash_zone.new(self, collision)
		if not danger_dash_zone_inst.get_parent():
			add_child(danger_dash_zone_inst)
	danger_dash_zone_inst.start_cooldown(call_back)

func to_full_charge():
	stop_countdown()
	current_state = state.AIM
	aiming = false

func destroy(without_point = false):
	if visible:
		ExplodeEffect.explode(self)
	if not without_point:
		ScoreControl.score_delta(50)
	stop_countdown()
	ReuseInitialize.to_reuse(GroupsName.CROWD, self)
