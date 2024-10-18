extends Node2D

@onready var spawn_control = get_parent().get_node("spawn_control")
@onready var balloon = get_tree().get_first_node_in_group(GroupsName.BALLOON)

var fall_floor = preload("res://nodes/floors/fall_floor.tscn")
var obs_floor = preload("res://nodes/floors/obstacle_floor.tscn")
var normal_floor = preload("res://nodes/floors/normal_floor.tscn")
var spawn_enemies_dash = preload("res://script/system_control/spawn_enemies_dash.gd")

var boss = preload("res://nodes/enemies/boss.tscn")

enum floor_types {
	RANDOM, ##floor แบบ random เป็นได้ทั้งพื้นปกติไม่มีอะไรหรือพื้นที่มีอุปสรรคกีดขวาง
	OBSTACLE, ##floor แบบที่มีสิ่งกีดขวางบังทางตัวละคร
	FALL, ##floor แบบที่มีสิ่งกีดขวางแบบหลุม
	EVENT, ##floor สำหรับ trigger event อะไรบางอย่าง โดยพื้นที่ player วิ่งจะเป็นพื้นปกติจนกว่าจะจบ event
}

var floors_path = [
	##[ประเภทพื้นที่จะ spawn, จำนวนพื้นที่จะ spawn, function ที่จะทำงานเมื่อเริ่ม spawn พื้น]
	
	#[floor_types.RANDOM, 1],
	[floor_types.FALL, 1, func():
		spawn_control.create(spawn_enemies_dash).start()
		],
	[floor_types.OBSTACLE, 1, func():
		spawn_control.create(spawn_enemies_dash).start()
		],
	#[floor_types.EVENT, 1, func():
		#get_tree().paused = true
		#BalloonControl.set_on_finish_balloon(func():
			##เมื่อจะจบ event ให้ใช้ end_event() เพื่อทำการดำเนินการ spawn floor อันถัดไป
			#end_event()
			#get_tree().paused = false
			#)
		#balloon.start(load("res://dialogues/test1_dialog.dialogue"),"this_is_a_node_title")
		#],
	##[floor_types.EVENT, 1, func():
		##ตย. บังคับ spawn floor
		##run_force_floor(floor_types.OBSTACLE, true)
		##],
	#[floor_types.RANDOM, 5],
	#[floor_types.RANDOM, 1, func():
		#spawn_control.create(spawn_enemies_dash).start()
		#],
	#[floor_types.RANDOM, 10],
	#[floor_types.RANDOM, 1, func():
		#spawn_control.create(spawn_enemies_dash).start()
		#],
	##Floor สุดท้ายจะบังคับเป็น floor ที่เจอกับบอสอัตโนมัติ
]
var max_floor_buffer = 3
var scene_floor_min_count = 0
var is_event_end = false
var triggered_event = false
var is_reset = false
var floors = []
var event = trigger_boss_event
var boss_event

var force_floor = null
var is_force_floor_loop = false
var is_spawnable_coin = true

signal done_reset

@onready var current_child = self.get_child(0)
@onready var first_floor_pos = current_child.position
@onready var center_pos = current_child.position

func _ready():
	if not is_in_group(GroupsName.FLOOR_CONTROL):
		add_to_group(GroupsName.FLOOR_CONTROL)
	randomize()
	floors.append(current_child)
	boss_event = func():
		var boss_inst = boss.instantiate()
		get_parent().add_child(boss_inst)
		boss_inst.spawn(Vector2(get_viewport_rect().size.x, first_floor_pos.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not triggered_event and scene_floor_min_count > max_floor_buffer and event:
		triggered_event = true
		spawn_control.force_stop_all_events()
		event.call()
	var new_floor
	if not is_reset:
		if floors.size() <= max_floor_buffer:
			new_floor = get_next_floor().instantiate()
			add_child(new_floor)
			new_floor.position = current_child.position
			new_floor.position.x = new_floor.position.x + get_floor_size(new_floor)
			floors.push_front(new_floor)
			current_child = new_floor

		for _floor in floors:
			if is_instance_valid(_floor):
				_floor.position.x = _floor.position.x - 10
				if _floor.position.x < center_pos.x - get_floor_size(_floor):
					_floor.queue_free()
					floors.remove_at(floors.find(_floor))
	else:
		if floors.size() > 0:
			floors.pop_back().queue_free()
		
		var _normal_floor = normal_floor.instantiate()
		_normal_floor.position = first_floor_pos
		add_child(_normal_floor)
		floors.push_front(_normal_floor)
		var pos_prev_floor_x = _normal_floor.position.x
		for _floor in floors:
			_floor.position.x = pos_prev_floor_x
			pos_prev_floor_x = pos_prev_floor_x + get_floor_size(_floor)
			current_child = _floor
		is_reset = false
		done_reset.emit()

func get_next_floor():
	var floor_type = null
	var floor_event = null
	
	if force_floor:
		var fl = force_floor
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
			
		if floor_type != null and floor_type != floor_types.EVENT:
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

func trigger_boss_event():
	if boss_event:
		boss_event.call()
