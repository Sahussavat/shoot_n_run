extends Control

@onready var current_score_text = get_node("score_text/current_score/score")
@onready var highest_score_text = get_node("score_text/highest_score/score")

@export var is_reset_control = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().get_first_node_in_group(GroupsName.PLAYER)
	if player and not ChangePage.is_changing_page:
		player.health.health.add_on_death(func():
			#if is_reset_control:
				#ScoreControl.reset()
			player.visible = false
			PlayerDeathEffect.do_game_over_effect(player, player.global_position, func():
				process_mode = Node.PROCESS_MODE_ALWAYS
				get_tree().paused = true
				get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_in(func():
					var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
					menu.process_mode = Node.PROCESS_MODE_DISABLED
					ScoreControl.set_current_scene_name()
					show_score()
					visible = true
					, 0.5)
			)
		)
	else:
		show_score()
	

func show_score():
	current_score_text.text = str(ScoreControl.score)
	var h_s = ScoreControl.load_highest_score()
	if h_s < ScoreControl.score:
		highest_score_text.text = current_score_text.text
		ScoreControl.save_highest_score()
	else:
		highest_score_text.text = str(h_s)
	ScoreControl.reset()
