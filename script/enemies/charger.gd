extends CharacterBody2D

enum state {
	MOVE,
	MOVE_AND_AIM,
	CHARGE,
	RETRET
}

var current_state = state.RETRET

var SPEED = 800
var CHARGE_SPEED = 20

var timer
var danger_dash_zone_inst
var charge_direction = 1

var max_health = 25
var health = preload("res://script/system_control/health.gd")
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
var fly_movement = preload("res://script/enemies/fly_movement.gd")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var wait_for_attack = Timer.new()
@onready var collision = get_collision(self)

func _ready():
	add_to_group(GroupsName.ENEMIES)
	health = health.new(max_health)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.add_on_death(destroy)
	health_bar_control.new(self, health)
	wait_for_attack.wait_time = 1
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
			fly_movement.move_center(_delta)
		state.MOVE_AND_AIM:
			if not danger_dash_zone_inst:
				danger_dash_zone_inst = danger_dash_zone.new(self, collision)
				danger_dash_zone_inst.start_cooldown(func():
					current_state = state.CHARGE
					)
			else:
				danger_dash_zone_inst.follow(player)
			fly_movement.move_center(_delta)
		state.CHARGE:
			fly_movement.charge(_delta, player.global_position, func():
				current_state = state.RETRET
				)

		state.RETRET:
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

func reset_atk():
	current_state = state.MOVE_AND_AIM
		
func destroy():
	ExplodeEffect.explode(self)
	ScoreControl.score_delta(50)
	queue_free()

