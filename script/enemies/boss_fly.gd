extends CharacterBody2D

var boss_name = "arlin"
var cooldown_next_timer = Timer.new()
var cooldown_in_half_hp = Timer.new()
var health = preload("res://script/system_control/health.gd")
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health_bar_control = preload("res://script/system_control/health_bar.gd")
var fly_movement = preload("res://script/enemies/fly_movement.gd")
var multi_shot = preload("res://script/enemies/multi_shot.gd")
var circle_shot = preload("res://script/enemies/circle_shots.gd")
var ricochet = preload("res://script/enemies/richochet.gd")
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
@onready var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
@onready var spawn_control = floors_control.spawn_control
@onready var boss_bar = get_tree().get_first_node_in_group(GroupsName.BOSS_BAR)
@onready var minigames = get_tree().get_first_node_in_group(GroupsName.MINIGAMES)

var wait_to_attack_end_fn
var is_cooldown_next = false
var current_i_atk = -1
var current_move 
var is_in_half_hp_mode = false
var is_cooldown_in_half_hp = false
var enable_to_attack = false
var attack_duration = 0

var pass_question1 = false
var pass_question2 = false

enum attack_type {
	RANDOM,
	SPAWN_OBS_FLOOR, ##spawn พื้นสิ่งกีดขวาง
	SPAWN_DASH_ENEMIES, ##spawn กลุ่มปลาบินใส่ player
	RETREAT
}

enum move_type {
	FLY,
	RICOCHET,
	RICOCHET_2_FLY,
}

var attacks_seq = [
	attack_type.RETREAT,
	attack_type.SPAWN_OBS_FLOOR,
	attack_type.SPAWN_DASH_ENEMIES,
]

func _ready():
	cooldown_next_timer.wait_time = 1
	cooldown_next_timer.one_shot = true
	cooldown_next_timer.timeout.connect(func():
		is_cooldown_next = false
		)
	add_child(cooldown_next_timer)
	cooldown_in_half_hp.wait_time = 2
	cooldown_in_half_hp.one_shot = true
	cooldown_in_half_hp.timeout.connect(func():
		is_cooldown_in_half_hp = false
		)
	add_child(cooldown_in_half_hp)
	health = health.new(1000)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.change_health.connect(set_half_hp_mode)
	health.add_on_death(on_death)
	health_bar_control = health_bar_control.new(boss_bar, health)
	boss_bar.set_visible(true)
	add_to_group(GroupsName.BOSS)
	
	fly_movement = fly_movement.new(self)
	ricochet = ricochet.new(self, 10)
	multi_shot = multi_shot.new(self)
	circle_shot = circle_shot.new(self)
	
	set_move_by_type(move_type.RICOCHET_2_FLY)

func _physics_process(_delta):
	current_move.call(_delta)
	if is_wait_end() and not is_cooldown_next and not is_cooldown_in_half_hp and enable_to_attack:
		is_cooldown_next = true
		get_next_attack().call()
		cooldown_next_timer.start()

func set_half_hp_mode():
	if health.health <= health.max_health/2.0 and not is_in_half_hp_mode:
		is_in_half_hp_mode = true
		is_cooldown_in_half_hp = true
		cooldown_next_timer.wait_time = 0.5
		spawn_control.force_stop_all_events()
		cooldown_in_half_hp.start()
		$Sprite2D.material = ShaderMaterial.new()
		$Sprite2D.material.shader = preload("res://shader/anger_boss_color.gdshader")
	elif health.health <= health.max_health/1.5 and not pass_question1:
		slow_motion(0.05)
		get_tree().paused = true
		minigames.run_the_game(minigames.game_type.QUICK_TYPE, 
		func():
			pass_question1 = true
			get_tree().paused = false
			slow_motion()
			, 
		func():
			health.set_health(health.max_health)
			get_tree().paused = false
			slow_motion()
			)
	elif health.health <= health.max_health/2.5 and not pass_question2:
		slow_motion(0.05)
		get_tree().paused = true
		minigames.run_the_game(minigames.game_type.SPEECH_TYPE, 
		func():
			pass_question2 = true
			get_tree().paused = false
			slow_motion()
			, 
		func():
			health.set_health(health.max_health * 0.5)
			get_tree().paused = false
			slow_motion()
			)
func change_scene():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(func():
		ScoreControl.score_delta(150)
		ChangePage.change_to_target_scene("res://nodes/worlds/credit.tscn")
	)


func on_death():
	slow_motion(0.05)
	minigames.run_the_game(minigames.game_type.CALCULATE_TYPE, 
	func():
		slow_motion()
		get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_out(change_scene)
		,
	func():
		health.set_health(health.max_health * 0.5)
		get_tree().paused = false
		slow_motion()
		)
	get_tree().paused = true

func get_next_attack():
	current_i_atk = current_i_atk + 1
	current_i_atk = current_i_atk % attacks_seq.size()
	return get_attack_by_type(attacks_seq[current_i_atk])

func is_wait_end():
	if (not wait_to_attack_end_fn) or (wait_to_attack_end_fn and wait_to_attack_end_fn.call()):
		wait_to_attack_end_fn = null
		return true
	return false

func spawn(spawn_pos):
	position = spawn_pos
	move_init()

func move_init():
	var collision_size = get_collision().shape.size.x
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x - (collision_size + 50), position.y), 0.5)
	tween.tween_callback(func():
		enable_to_attack = true
		)

func get_attack_by_type(type):
	var spawn_obs_floor = func():
				multi_shot.create_shots(50, 0.1, player)
				set_move_by_type(move_type.FLY)
				wait_to_attack_end_fn = func():
					return multi_shot.is_shot_empty
	var spawn_dash_enemies = func():
				multi_shot.create_shots(50, 0.1, player)
				set_move_by_type(move_type.RICOCHET)
				wait_to_attack_end_fn = func():
					return multi_shot.is_shot_empty
	var retreat = func():
				set_move_by_type(move_type.RICOCHET_2_FLY, func():
					circle_shot.create_shots(25)
					)
				wait_to_attack_end_fn = func():
					return false
	match type:
		attack_type.RANDOM:
			var atks = [
				spawn_dash_enemies,
				spawn_obs_floor,
			]
			return atks[randi_range(0, atks.size() - 1)]
		attack_type.SPAWN_OBS_FLOOR:
			return spawn_obs_floor
		attack_type.SPAWN_DASH_ENEMIES:
			return spawn_dash_enemies
		attack_type.RETREAT:
			return retreat

func set_move_by_type(type_name, callback = null):
	match type_name:
		move_type.RICOCHET:
			current_move = func(delta):
				ricochet.move(delta)
		move_type.FLY:
			current_move = func(delta):
				fly_movement.move_center(delta)
		move_type.RICOCHET_2_FLY:
			current_move = func(delta):
				fly_movement.retret(delta, func():
					set_move_by_type(move_type.FLY)
					callback.call()
					wait_to_attack_end_fn = null
					)

func get_collision():
	var children = get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null

func do_clock_durarion(wait_time):
	attack_duration += 1
	if wait_time == attack_duration:
		attack_duration = 0
		return true
	return false

func slow_motion(t = 0.1):
	Engine.time_scale = 0.1
	await get_tree().create_timer(t).timeout
	Engine.time_scale = 1
