extends CharacterBody2D

var MAX_SPEED = 50
var SEPERATION_RADIUS = 150
var MAX_SEPRATION = 4

var max_health = 25
var crowd_group
var max_velocity = 10
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health = preload("res://script/system_control/health.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.ENEMIES)
	health = health.new(max_health)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.add_on_death(destroy)
	health_bar_control.new(self, health)
	add_to_group(GroupsName.CROWD)
	EntitiesGroup.add_entity_to_group(GroupsName.CROWD, self)
	crowd_group = EntitiesGroup.groups[GroupsName.CROWD]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global_position.distance_to(player.global_position) > 10:
		global_position += seek(player.global_position) + seperation() * 0.5 + velocity * pow(MAX_SPEED, 2) * _delta

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

func destroy():
	EntitiesGroup.remove_entity_from_group(GroupsName.CROWD, self)
	ExplodeEffect.explode(self)
	ScoreControl.score_delta(50)
	queue_free()
