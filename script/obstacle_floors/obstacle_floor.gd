extends StaticBody2D

enum obs {
	OBSTACLE,
	BLANK
}

var obs_obj = preload("res://nodes/hitbox_objs/obstacle_typ_1.tscn")
var coin = preload("res://nodes/hitbox_objs/coin.tscn")

var num_spawn_sec = 6.0
var obstacle_max = 2
var blank_max = 4

var is_spawnable_coin = true

@onready var colorRect = $floor
@onready var floor_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL).floor_control
# Called when the node enters the scene tree for the first time.
func _ready():
	is_spawnable_coin = floor_control.is_spawnable_coin
	var color = Color(randf(),randf(),randf())
	colorRect.color = color
	var i = 0
	var obs_num = 0
	var blank_num = 0
	var rand_obs
	while (i < num_spawn_sec):
		rand_obs = randi_range(0, 1)
		if (blank_num < blank_max and (rand_obs == 0 or blank_num > 0)) or obs_num >= obstacle_max:
			blank_num = blank_num + 1
			obs_num = 0
			if is_spawnable_coin:
				var coin_inst = coin.instantiate()
				coin_inst.position = get_spawn_pos_at(i)
				coin_inst.position.y = coin_inst.position.y - 50
				add_child(coin_inst)
		elif (obs_num < obstacle_max and rand_obs == 1) or blank_num >= blank_max:
			obs_num = obs_num + 1
			blank_num = 0
			var obs_obj_inst = obs_obj.instantiate()
			obs_obj_inst.position = get_spawn_pos_at(i)
			add_child(obs_obj_inst)
			if is_spawnable_coin:
				var coin_inst = coin.instantiate()
				coin_inst.position = obs_obj_inst.position
				coin_inst.position.y = coin_inst.position.y - (get_collision(obs_obj_inst).shape.size.y + 50)
				add_child(coin_inst)
		i = i + 1
	pass # Replace with function body.

func get_spawn_pos_at(index):
	var spawn_pos_y = colorRect.position.y
	
	var left_edage_pos = colorRect.position.x 
	var spawn_pos_sec_length = colorRect.size.x / num_spawn_sec
	var start_index_pos = left_edage_pos + spawn_pos_sec_length * index
	var center_length = spawn_pos_sec_length / 2.0
	var spawn_pos_x = start_index_pos + center_length
	return Vector2(spawn_pos_x, spawn_pos_y)

func get_collision(obj):
	var children = obj.get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
