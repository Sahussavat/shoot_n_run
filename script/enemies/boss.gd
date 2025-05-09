extends StaticBody2D

var cooldown_next_timer = Timer.new()
var cooldown_in_half_hp = Timer.new()
var health = preload("res://script/system_control/health.gd")
var hit_flash = preload("res://script/system_control/hit_flash.gd")
var health_bar_control = preload("res://script/system_control/health_bar.gd")
@onready var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL).floor_control
@onready var boss_bar = get_tree().get_first_node_in_group(GroupsName.BOSS_BAR)
@onready var minigames = get_tree().get_first_node_in_group(GroupsName.MINIGAMES)
@onready var animation_player = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)

@export var chosen_minigame = 0
@export var store_next_world = "world"
@export var boss_name = "อาลิน"

@export var end_dialogue_target : String
@export var end_dialogue_sub_target : String

var wait_to_attack_end_fn
var is_cooldown_next = false
var current_i_atk = -1
var is_in_half_hp_mode = false
var is_cooldown_in_half_hp = false
var enable_to_attack = false

var is_game_running = true

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
	health = health.new(100)
	health.is_invicible = true
	hit_flash = hit_flash.new(self)
	health_bar_control = health_bar_control.new(boss_bar, health)
	boss_bar.set_visible(true)
	animation_player.play("run")
	add_to_group(GroupsName.BOSS)

func _physics_process(_delta):
	if is_game_running and enable_to_attack and not player.health.is_dead():
		is_game_running = false
		await get_tree().create_timer(1.5, false).timeout
		get_tree().paused = true
		minigames.run_the_game(chosen_minigame,
		func():
			get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_out(change_scene)
			, 
		func():
			player.health.health.is_invicible = false
			player.health.health.do_damage(player.health.health.max_health * 0.34)
			if player.animation_player.is_playing():
				player.animation_player.stop()
			player.animation_player.play("hurt_frame")
			get_tree().paused = false
			is_game_running = true
			)

func change_scene():
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.05).timeout
	Engine.time_scale = 1
	get_tree().get_first_node_in_group(GroupsName.MENU).process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(func():
		BalloonControl.set_on_finish_balloon(func():
			ScoreControl.score_delta(150)
			ChangePage.store_next_world(store_next_world)
			ChangePage.change_to_target_scene("res://nodes/worlds/score.tscn")
			)
		DialogueUtill.get_balloon().start(load("res://dialogues/intro_map1.dialogue"),"end_boss_1")
	)

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

func get_collision():
	var children = get_children()
	for child in children:
		if child is CollisionShape2D:
			return child
	return null
