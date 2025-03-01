extends Node

var floors_path_len = 0

var current_floor_path = 0
var current_amount_floor_path = -1
var enable_load = false

func _ready():
	var f = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
	if f:
		floors_path_len = f.floors_path.size()

func save_floor_position(floors_path):
	current_floor_path = floors_path_len - floors_path.size()
	if floors_path.size() > 0:
		current_amount_floor_path = floors_path[0][1]

func load_floor_position(floors_path):
	if enable_load:
		for i in range(0, current_floor_path):
			floors_path.pop_front()
		if floors_path.size() > 0 and current_amount_floor_path > -1:
			floors_path[0][1] = current_amount_floor_path
		current_floor_path = 0
		current_amount_floor_path = -1
		enable_load = false

func enable_load_floor():
	enable_load = true
