extends Node2D

var floor_control = preload("res://script/system_control/floors.gd")
var boss = preload("res://nodes/enemies/boss_fly.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	floor_control = floor_control.new(self)
	floor_control.setting(
		[
			##[ประเภทพื้นที่จะ spawn, จำนวนพื้นที่จะ spawn, function ที่จะทำงานเมื่อเริ่ม spawn พื้น]
			
			#[floor_types.RANDOM, 1],
			[floor_control.floor_types.EVENT, 1, func():
				pass
				],
			#[floor_control.floor_types.RANDOM, 1, func():
				#get_tree().get_first_node_in_group(GroupsName.TUTORIAL).show_popup()
				#],
			#[floor_control.floor_types.EVENT, 1, func():
				#floor_control.spawn_control.is_running = false
				#var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
				#var temp_menu = menu.process_mode
				#menu.process_mode = Node.PROCESS_MODE_DISABLED
				#get_tree().paused = true
				#BalloonControl.set_on_finish_balloon(func():
					#get_tree().get_first_node_in_group(GroupsName.CUTSCENE).run_other_cutscene_fn = func():
						#get_tree().get_first_node_in_group(GroupsName.CUTSCENE).visible = false
						#get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_out(func():
							#floor_control.end_event()
							#get_tree().paused = false
							#menu.process_mode = temp_menu
							#)
					#get_tree().get_first_node_in_group(GroupsName.CUTSCENE).play_video_path("res://videoes/partner-covered-by-takopero-1080-publer.io.ogv")
					#get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_out()
					#)
					#
				#get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(func():
					#DialogueUtill.get_balloon().start(load("res://dialogues/test1_dialog.dialogue"),"this_is_a_node_title")
					#)
				#],
			[floor_control.floor_types.RANDOM, 25, func():
				FloorsUtill.save_floor_position(floor_control.floors_path)
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
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_multi_shot_flyer, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_circle_flyer, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_ricocheter, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_dash_stair, func():
				return true;
				, 10),
			floor_control.spawn_control.spawn_data(floor_control.spawn_enemies_dash_half_screen, func():
				return true;
				, 10),
		],
		
		func():
			var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
			var temp_menu = menu.process_mode
			menu.process_mode = Node.PROCESS_MODE_DISABLED
			get_tree().paused = true
			BalloonControl.set_on_finish_balloon(func():
				get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_out(func():
					get_tree().paused = false
					menu.process_mode = temp_menu
					
					var boss_inst = boss.instantiate()
					get_parent().add_child(boss_inst)
					boss_inst.spawn(Vector2(get_viewport_rect().size.x, floor_control.first_floor_pos.y))
					)
				)
			get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(func():
				DialogueUtill.get_balloon().start(load("res://dialogues/intro_map3.dialogue"),"meet_boss_3")
				)
	)

	FloorsUtill.set_floor_control(floor_control)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	floor_control._process(delta)

func end_event():
	floor_control.end_event()
