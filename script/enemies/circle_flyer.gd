extends CharacterBody2D

enum state {
	MOVE,
	MOVE_AND_AIM,
	AIM,
	FULL_CHARGE,
	RETREAT
}

var current_state = state.RETREAT

var SPEED = 800

var max_health = 25

var timer
var danger_dash_zone_inst
var aiming = false

var health = preload("res://script/system_control/health.gd")
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
var fly_movement = preload("res://script/enemies/fly_movement.gd")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var toxic_bullet = preload("res://nodes/hitbox_objs/toxic_bullet.tscn")
var circle_shot = preload("res://script/enemies/circle_shots.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var wait_for_attack = Timer.new()
@onready var wait_for_self_bullet = Timer.new()
@onready var collision = get_collision(self)

func _ready():
	add_to_group(GroupsName.ENEMIES)
	health = health.new(max_health)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.add_on_death(destroy)
	health_bar_control = health_bar_control.new(self, health)
	wait_for_attack.wait_time = 2.5
	wait_for_attack.one_shot = true
	wait_for_attack.timeout.connect(reset_atk)
	add_child(wait_for_attack)
	wait_for_self_bullet.wait_time = 10
	wait_for_self_bullet.one_shot = true
	wait_for_self_bullet.timeout.connect(to_full_charge)
	add_child(wait_for_self_bullet)
	fly_movement = fly_movement.new(self)
	
	circle_shot = circle_shot.new(self)
	circle_shot.speed = 15
	circle_shot.shot_empty.connect(func():
		current_state = state.MOVE
		aiming = false
		)

func _re_ready():
	health.revive()
	health_bar_control.reset_bar()
	
	current_state = state.RETREAT
	
	wait_for_attack.free()
	wait_for_attack = Timer.new()
	wait_for_attack.wait_time = 1
	wait_for_attack.one_shot = true
	wait_for_attack.timeout.connect(reset_atk)
	add_child(wait_for_attack)
	
	wait_for_self_bullet.free()
	wait_for_self_bullet = Timer.new()
	wait_for_self_bullet.wait_time = 10
	wait_for_self_bullet.one_shot = true
	wait_for_self_bullet.timeout.connect(to_full_charge)
	add_child(wait_for_self_bullet)

var angle = 0.1
var direction = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	match current_state:
		state.MOVE:
			if wait_for_attack.is_stopped():
				wait_for_attack.start()
			if wait_for_self_bullet.is_stopped():
				wait_for_self_bullet.start()
			fly_movement.move_center(_delta)
		state.MOVE_AND_AIM:
			if not aiming:
				aiming = true
				circle_shot.is_shot_empty = false
				circle_shot.create_shots(25, 0.25)
			fly_movement.move_center(_delta)
			
		state.AIM:
			if not aiming:
				aiming = true
				danger_dash_zone_init(func():
					current_state = state.FULL_CHARGE
					circle_shot.pause_shot = true
					aiming = false
				)
			else:
				danger_dash_zone_inst.follow(player)
		state.FULL_CHARGE:
			fly_movement.full_charge(_delta, player.global_position, func():
				destroy(true)
				)
		state.RETREAT:
			fly_movement.retret(_delta, func():
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

func to_full_charge():
	stop_countdown()
	current_state = state.AIM
	aiming = false

func reset_atk():
	current_state = state.MOVE_AND_AIM

func danger_dash_zone_init(call_back):
	if not danger_dash_zone_inst:
		danger_dash_zone_inst = danger_dash_zone.new(self, collision)
		if not danger_dash_zone_inst.get_parent():
			add_child(danger_dash_zone_inst)
	danger_dash_zone_inst.start_cooldown(call_back)

func stop_countdown():
	wait_for_self_bullet.stop()
	wait_for_attack.stop()
	if is_instance_valid(danger_dash_zone_inst) and danger_dash_zone_inst:
		danger_dash_zone_inst.destroy()

func destroy(without_point = false):
	if visible:
		ExplodeEffect.explode(self)
	if not without_point:
		ScoreControl.score_delta(50)
	ReuseInitialize.to_reuse(GroupsName.CIRCLE_FLYER ,self)
	stop_countdown()
	current_state = state.MOVE
	fly_movement.charge_direction = null
	aiming = false
