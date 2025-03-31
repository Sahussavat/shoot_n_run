extends Area2D

var obstacle_damage_obj = preload("res://script/hitbox_obj/obstacle_damage_obj.gd")

@onready var canvas = get_parent().get_parent().get_node("CanvasLayer")
@onready var player = get_parent().get_parent().get_node("tako")
@onready var spawn_pos = player.position
@onready var floors = get_parent().get_parent().get_node("floors").floor_control
var lowest_collision_y

func _ready():
	obstacle_damage_obj = obstacle_damage_obj.new()
	obstacle_damage_obj.damage = 30
	spawn_pos.y = spawn_pos.y - 500
	floors.done_reset.connect(respawn)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	var lowest_collision = get_lowest_collision()
	lowest_collision_y = lowest_collision.position.y + lowest_collision.shape.size.y / 4.0

func _process(_delta):
	if player.position.y > lowest_collision_y:
		do_respawn_with_fade()

func get_lowest_collision():
	var children = get_children()
	var _lowest_collision
	var highest_y = -INF
	for child in children:
		if child.position.y > highest_y:
			highest_y = child.position.y
			_lowest_collision = child
	return _lowest_collision

func _on_body_entered(_body):
	do_respawn_with_fade()

func _on_area_entered(area):
	obstacle_damage_obj._on_area_entered(area)

func do_respawn_with_fade():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).fade_in(func():
			floors.is_reset = true
			)

func respawn():
	player.position = spawn_pos
