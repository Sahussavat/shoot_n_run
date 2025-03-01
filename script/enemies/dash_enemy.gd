extends StaticBody2D

const MAX_SPEED = 2

@export var max_health = 25
var destroy_timer = Timer.new()
var is_lauchable = false
var danger_dash_zone = preload("res://script/system_control/danger_dash_zone.gd")
var health = preload("res://script/system_control/health.gd")
var health_bar_control = preload("res://script/system_control/enemy_health_bar.gd")
@onready var dash_collision = get_node("dash_collision")
@onready var collision_height = dash_collision.shape.size.y
@onready var collision_y = position.y

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.ENEMIES)
	health = health.new(max_health)
	health.add_on_death(destroy)
	health_bar_control.new(self, health)
	destroy_timer.wait_time = 10
	destroy_timer.one_shot = true
	destroy_timer.timeout.connect(destroy)
	add_child(destroy_timer)
	var danger_dash_zone_inst = danger_dash_zone.new(self, dash_collision)
	danger_dash_zone_inst.start_cooldown(func():
		is_lauchable = true
		destroy_timer.start()
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_lauchable:
		lauch()

func lauch():
	position = position + transform.x * MAX_SPEED

func rotate_by_target(target):
	var target_pos
	if target is Vector2:
		target_pos = target
	else:
		target_pos = target.global_position
	target_pos.y = target_pos.y - collision_height/2.0
	var degrees = global_position.direction_to(target_pos).angle()
	rotation = degrees

func rotate_by_degrees(degrees):
	rotation = deg_to_rad(degrees)

func do_mirror():
	scale.x = scale.x * -1

func destroy():
	queue_free()
