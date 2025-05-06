extends Node2D

var floor_control = preload("res://script/system_control/floors.gd")

var is_boss_spawned = false
var boss_per_turn = 5
var turn = 0

var boss

# Called when the node enters the scene tree for the first time.
func _ready():
	floor_control = floor_control.new(self)
	floor_control.is_speedup_enable = true
	floor_control.stop_all_event_once = true
	floor_control.setting(
		[
			[floor_control.floor_types.EVENT, 1, func():
				pass
				],
		],
		
		[
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_flyer, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_charger, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_dash, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_crowd, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_boss, func():
				if (turn >= boss_per_turn and turn > 0):
					turn = 0
					if not is_boss_spawned:
						is_boss_spawned = true
						return true
				turn += 1
				return false;
				, 1),
		],
		
		func():
			floor_control.run_force_floor(floor_control.floor_types.RANDOM_LOOP, true)
			floor_control.spawn_control.start_spawn_list()
	)

	FloorsUtill.set_floor_control(floor_control)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	floor_control._process(delta)

func end_event():
	floor_control.end_event()

func boss_dead():
	is_boss_spawned = false
