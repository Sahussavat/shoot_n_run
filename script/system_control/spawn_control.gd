extends Node2D

signal stop_events
var spawn_list = []
var spawn_list_temp = []
var wait_for_next_battle = 3
var timer = Timer.new()
var current_spawner
var is_running = false
var pause_next_battle = false
var is_first_time_count = true
var max_enemies = 0

func _ready():
	ReuseInitialize.reset_used_entities()
	timer.autostart = false
	timer.timeout.connect(start_spawn_list)
	add_child(timer)
	if not is_in_group(GroupsName.SPAWN_CONTROL):
		add_to_group(GroupsName.SPAWN_CONTROL)

func create(run_event):
	return run_event.new(self)

func start_spawn_list():
	is_running = true
	var curret_battle = get_curret_battle()
	if not curret_battle:
		return
	current_spawner = create(curret_battle["spawner"])
	current_spawner.out_of_enemies.connect(cancel_and_go_next_battle)
	current_spawner.start()
	if is_first_time_count:
		max_enemies += current_spawner.max_enemies
	timer.wait_time = curret_battle["fight_duration"]
	timer.start()

func cancel_and_go_next_battle():
	if timer:
		timer.stop()
	timer.wait_time = wait_for_next_battle
	if not pause_next_battle:
		timer.start()

func get_curret_battle():
	if spawn_list.size() == 0:
		return
	if spawn_list_temp.size() == 0:
		is_first_time_count = false
		spawn_list_temp = spawn_list.duplicate()
		spawn_list_temp.shuffle()
	var curret_battle
	while spawn_list_temp.size():
		curret_battle = spawn_list_temp.pop_front()
		if curret_battle["spawn_condition"].call():
			break;
		else:
			curret_battle = null
	return curret_battle

func set_spawn_list(_spawn_list):
	spawn_list = _spawn_list

func spawn_data(spawner, spawn_con_call_back, fight_duration):
	return {
			"spawner" : spawner,
			"spawn_condition" : spawn_con_call_back,
			"fight_duration": fight_duration, 
			}
	
func force_stop_all_events():
	if timer:
		timer.stop()
	stop_events.emit()
	pause_next_battle = true
	remove_all_enemies()
	pause_next_battle = false

func remove_all_enemies():
	ScoreControl.is_turn_off_score_delta = true
	get_tree().call_group(GroupsName.ENEMIES, "destroy")
	ScoreControl.is_turn_off_score_delta = false
	
