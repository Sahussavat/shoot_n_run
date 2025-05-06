extends Node2D

var spawn_control

var fall_floor = preload("res://nodes/floors/fall_floor.tscn")
var obs_floor = preload("res://nodes/floors/obstacle_floor.tscn")
var normal_floor = preload("res://nodes/floors/normal_floor.tscn")
var spawn_enemies_dash = preload("res://script/system_control/spawn_enemies_dash.gd")
var spawn_enemies_charger = preload("res://script/system_control/spawn_enemies_charger.gd")
var spawn_enemies_crowd = preload("res://script/system_control/spawn_enemies_crowd.gd")
var spawn_enemies_flyer = preload("res://script/system_control/spawn_enemies_flyer.gd")
var spawn_boss = preload("res://script/system_control/spawn_boss.gd")

var boss = preload("res://nodes/enemies/boss.tscn")

enum floor_types {
	RANDOM, ##floor แบบ random เป็นได้ทั้งพื้นปกติไม่มีอะไรหรือพื้นที่มีอุปสรรคกีดขวาง
	RANDOM_LOOP,
	OBSTACLE, ##floor แบบที่มีสิ่งกีดขวางบังทางตัวละคร
	FALL, ##floor แบบที่มีสิ่งกีดขวางแบบหลุม
	EVENT, ##floor สำหรับ trigger event อะไรบางอย่าง โดยพื้นที่ player วิ่งจะเป็นพื้นปกติจนกว่าจะจบ event
}

var floor_count = 0
var max_floor_count = 20
var is_speedup_enable = false

var floors_path
var max_floor_buffer = 3
var scene_floor_min_count = 0
var is_event_end = false
var is_force_run_event = true
var triggered_event = false
var is_reset = false
var floors = []
var event = trigger_boss_event
var boss_event

var force_floor = null
var is_force_floor_loop = false
var is_spawnable_coin = true

var stop_all_event_once = false

signal done_reset

var current_child
var first_floor_pos
var center_pos

var parent

func _init(_parent):
	parent = _parent
	spawn_control = parent.get_tree().get_first_node_in_group(GroupsName.SPAWN_CONTROL)
	SlowMotionVal.reset_slow_motion_val()

func setting(floors_data, spawn_data, boss_fn = func():
		pass):
	floors_path = floors_data
	current_child = parent.get_child(0)
	first_floor_pos = current_child.position
	center_pos = current_child.position
	spawn_control.set_spawn_list(spawn_data)
	FloorsUtill.load_floor_position(floors_path)
	if not parent.is_in_group(GroupsName.FLOOR_CONTROL):
		parent.add_to_group(GroupsName.FLOOR_CONTROL)
	randomize()
	floors.append(current_child)
	boss_event = boss_fn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_instance_valid(spawn_control) and not spawn_control.is_running and floors_path.size() > 0 and not is_force_run_event:
		spawn_control.start_spawn_list()
	if not triggered_event and scene_floor_min_count > max_floor_buffer and event:
		triggered_event = true
		if not stop_all_event_once:
			spawn_control.force_stop_all_events()
		stop_all_event_once = false
		event.call()
	var new_floor
	if not is_reset:
		if floors.size() <= max_floor_buffer:
			new_floor = get_next_floor().instantiate()
			parent.add_child(new_floor)
			new_floor.position = current_child.position
			new_floor.position.x = new_floor.position.x + get_floor_size(new_floor)
			floors.push_front(new_floor)
			current_child = new_floor
			if floor_count <= max_floor_count and is_speedup_enable:
				floor_count += 1;
				if floor_count > 5:
					SlowMotionVal.set_slow_motion_val(1.0 + float(floor_count)/max_floor_count * 0.5)
		for _floor in floors:
			if is_instance_valid(_floor):
				_floor.position.x = _floor.position.x - 500 * _delta * SlowMotionVal.slow_motion_val
				if _floor.position.x < center_pos.x - get_floor_size(_floor):
					_floor.queue_free()
					floors.remove_at(floors.find(_floor))
	else:
		if floors.size() > 0:
			floors.pop_back().queue_free()
		var _normal_floor = normal_floor.instantiate()
		_normal_floor.position = first_floor_pos
		parent.add_child(_normal_floor)
		floors.push_front(_normal_floor)
		var pos_prev_floor_x = _normal_floor.position.x
		for _floor in floors:
			_floor.position.x = pos_prev_floor_x
			pos_prev_floor_x = pos_prev_floor_x + get_floor_size(_floor)
			current_child = _floor
		is_reset = false
		scene_floor_min_count = -3
		done_reset.emit()

func get_next_floor():
	var floor_type = null
	var floor_event = null
	if force_floor:
		var fl = force_floor
		if force_floor == floor_types.RANDOM_LOOP:
			fl = get_floor_by_type(floor_types.RANDOM)
		if not is_force_floor_loop:
			force_floor = null
		return fl
	
	if not is_event_running():
		scene_floor_min_count = 0
		is_event_end = false
		triggered_event = false
		
		while floors_path.size() > 0:
			var current_floor = floors_path[0]
			if current_floor[1] > 0:
				current_floor[1] = current_floor[1] - 1
				floor_type = current_floor[0]
				if current_floor.size() > 2:
					floor_event = current_floor[2]
				break;
			else:
				floors_path.pop_front()
			
		if floor_type != null and floor_type != floor_types.EVENT and not is_force_run_event:
			if floor_event:
				floor_event.call()
			var fl = get_floor_by_type(floor_type)
			if fl:
				return fl
		else:
			scene_floor_min_count = 1
			if floor_type == floor_types.EVENT:
				event = floor_event
			else:
				event = trigger_boss_event
	elif scene_floor_min_count <= max_floor_buffer:
		scene_floor_min_count = scene_floor_min_count + 1
	return normal_floor

func run_force_floor(floor_type, is_loop = false):
	force_floor = get_floor_by_type(floor_type)
	is_force_floor_loop = is_loop

func stop_loop():
	is_force_floor_loop = false
	force_floor = null
	
func get_floor_by_type(floor_type):
	match floor_type:
		floor_types.RANDOM:
			var floor_arr = [
				obs_floor,
				fall_floor
			]
			var rand_floor_i = randi_range(0, floor_arr.size() - 1)
			return floor_arr[rand_floor_i]
		floor_types.RANDOM_LOOP:
			return floor_types.RANDOM_LOOP
		floor_types.OBSTACLE:
			return obs_floor
		floor_types.FALL:
			return fall_floor
	return null
			
func get_floor_size(_floor):
	var floor_color_rect = _floor.get_node_or_null("floor")
	if floor_color_rect:
		return _floor.get_node("floor").size.x
	else:
		return 1152;

func is_event_running():
	return scene_floor_min_count > 0 and not is_event_end

func end_event():
	is_event_end = true
	is_force_run_event = false

func trigger_boss_event():
	FloorsUtill.save_floor_position(floors_path)
	if boss_event:
		boss_event.call()

func run_event():
	is_force_run_event = true
