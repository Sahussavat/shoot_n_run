extends CharacterBody2D

enum state {
	MOVE,
	MOVE_AND_AIM,
	CHARGE,
	RETRET
}

var current_state = state.MOVE

var SPEED = 800
var CHARGE_SPEED = 20

var timer
var danger_dash_zone_inst
var charge_direction = 1

var fly_movement = preload("res://script/enemies/fly_movement.gd")
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var wait_for_attack = Timer.new()
@onready var collision = get_collision(self)

func _ready():
	wait_for_attack.wait_time = 5
	wait_for_attack.one_shot = true
	wait_for_attack.timeout.connect(reset_atk)
	add_child(wait_for_attack)
	fly_movement = fly_movement.new(self)

var angle = 0.1
var direction = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match current_state:
		state.MOVE:
			if wait_for_attack.is_stopped():
				wait_for_attack.start()
			fly_movement.move_center()
		state.MOVE_AND_AIM:
			if not danger_dash_zone_inst:
				danger_dash_zone_inst = danger_dash_zone.new(self, collision)
				danger_dash_zone_inst.start_cooldown(func():
					current_state = state.CHARGE
					charge_direction = global_position.direction_to(player.global_position)
					)
			else:
				danger_dash_zone_inst.follow(player)
			fly_movement.move_center()
		state.CHARGE:
			var charge_pos = global_position + charge_direction * CHARGE_SPEED
			
			var x = charge_pos.x;
			var y = charge_pos.y;
			
			if x > get_viewport_rect().size.x - fly_movement.dist_from_viewport:
				x = get_viewport_rect().size.x - fly_movement.dist_from_viewport
				current_state = state.RETRET
			elif x < fly_movement.dist_from_viewport:
				x = fly_movement.dist_from_viewport
				current_state = state.RETRET
			if y > get_viewport_rect().size.y + fly_movement.dist_from_viewport:
				y = get_viewport_rect().size.y + fly_movement.dist_from_viewport
				current_state = state.RETRET
			elif y < fly_movement.dist_from_viewport:
				y = fly_movement.dist_from_viewport
				current_state = state.RETRET
			
			global_position = Vector2(x, y)
		
		state.RETRET:
			var center_pos = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y)
			var left_pos = fly_movement.get_circle_position(center_pos, 0.6)
			var right_pos = fly_movement.get_circle_position(center_pos, 0.9)
			
			if left_pos.distance_to(global_position) <= right_pos.distance_to(global_position):
				global_position += global_position.direction_to(left_pos) * CHARGE_SPEED
				if left_pos.distance_to(global_position) <= 10:
					fly_movement.current_angle = 0.6
					current_state = state.MOVE
			else:
				global_position += global_position.direction_to(right_pos) * CHARGE_SPEED
				if right_pos.distance_to(global_position) <= 10:
					fly_movement.current_angle = 0.9
					current_state = state.MOVE

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
		


