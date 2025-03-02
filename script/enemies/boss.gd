extends StaticBody2D

var boss_name = "arlin"
var cooldown_next_timer = Timer.new()
var cooldown_in_half_hp = Timer.new()
var health = preload("res://script/system_control/health.gd")
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health_bar_control = preload("res://script/system_control/health_bar.gd")
@onready var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
@onready var spawn_control = floors_control.spawn_control
@onready var boss_bar = get_tree().get_first_node_in_group(GroupsName.BOSS_BAR)
@onready var minigames = get_tree().get_first_node_in_group(GroupsName.MINIGAMES)
@onready var animation_player = $AnimationPlayer

var wait_to_attack_end_fn
var is_cooldown_next = false
var current_i_atk = -1
var is_in_half_hp_mode = false
var is_cooldown_in_half_hp = false
var enable_to_attack = false

var pass_question1 = false
var pass_question2 = false

enum attack_type {
	RANDOM,
	SPAWN_OBS_FLOOR, ##spawn พื้นสิ่งกีดขวาง
	SPAWN_DASH_ENEMIES, ##spawn กลุ่มปลาบินใส่ player
}

var attacks_seq = [
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
	health = health.new(100)
	hit_flash = hit_flash.new(self)
	health.change_health.connect(hit_flash.do_hit_flash)
	health.change_health.connect(set_half_hp_mode)
	health.add_on_death(on_death)
	health_bar_control = health_bar_control.new(boss_bar, health)
	boss_bar.set_visible(true)
	animation_player.play("run")
	add_to_group(GroupsName.BOSS)

func _process(_delta):
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
		get_tree().paused = true
		minigames.run_the_game(minigames.game_type.QUICK_TYPE, 
		func():
			pass_question1 = true
			get_tree().paused = false
			, 
		func():
			health.set_health(health.max_health)
			get_tree().paused = false
			)
	elif health.health <= health.max_health/2.5 and not pass_question2:
		get_tree().paused = true
		minigames.run_the_game(minigames.game_type.SPEECH_TYPE, 
		func():
			pass_question2 = true
			get_tree().paused = false
			, 
		func():
			health.set_health(health.max_health * 0.5)
			get_tree().paused = false
			)

func on_death():
	minigames.run_the_game(minigames.game_type.CALCULATE_TYPE, 
	func():
		queue_free()
		ChangePage.change_to_target_scene("res://nodes/worlds/shop.tscn")
		, 
	func():
		health.set_health(health.max_health * 0.5)
		get_tree().paused = false
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
				floors_control.is_spawnable_coin = false
				floors_control.run_force_floor(floors_control.floor_types.OBSTACLE, true)
	var spawn_dash_enemies = func():
				var spawn_atk = spawn_control.create(floors_control.spawn_enemies_dash)
				spawn_atk.start()
				wait_to_attack_end_fn = func():
					return spawn_atk.is_stop()
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

func get_collision():
	var children = get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
