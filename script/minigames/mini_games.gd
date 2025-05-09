extends PanelContainer

enum game_type {
	SPEECH_TYPE, ##minigame ประเภทพูดตามคำบอก
	QUICK_TYPE, ##minigame ประเภทพิมพ์เร็ว
	CALCULATE_TYPE, ##minigame ประเภทคิดเลขไว
}

var menu
var temp_menu_process_mode = PROCESS_MODE_INHERIT

var character_left
var character_right

var current_game

var switching_game = false

# Called when the node enters the scene tree for the first time.
func run_the_game(_game_type, win_fn, lose_fn):
	var char_pics = get_tree().get_nodes_in_group(GroupsName.CHAR_PIC)
	for c in char_pics:
		if not character_left:
			character_left = c
			continue
		else:
			character_right = c
		if character_right.global_position.x < character_left.global_position.x:
			var temp = character_left
			character_left = character_right
			character_right = temp
	
	character_left.character_name = "เปโร่"
	var boss = get_tree().get_first_node_in_group(GroupsName.BOSS)
	if boss:
		character_right.character_name = boss.boss_name
	menu = get_tree().get_first_node_in_group(GroupsName.MENU)
	current_game = get_minigames(_game_type)
	if current_game:
		var game = current_game
		clear_all_connects(game)
		game.player_has_win.connect(func():
			win_fn.call()
			visible = false
			turn_off_game(game)
			)
		game.player_has_lose.connect(func():
			lose_fn.call()
			visible = false
			turn_off_game(game)
			)
		if is_inside_tree() and not switching_game:
			get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_in(func():
				visible = true
				turn_on_game(game)
				game.run()
				)

func get_minigames(_game_type):
	match _game_type:
		game_type.QUICK_TYPE:
			return $quick_type_game
		game_type.SPEECH_TYPE:
			return $speech_game
		game_type.CALCULATE_TYPE:
			return $cal_game

func turn_off_game(game):
	game.visible = false
	game.process_mode = Node.PROCESS_MODE_DISABLED
	if is_inside_tree() and not switching_game:
		get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_out(func():
			menu.process_mode = temp_menu_process_mode
			)
	enable_visible_character(false)

func turn_on_game(game): 
	game.process_mode = Node.PROCESS_MODE_ALWAYS
	temp_menu_process_mode = menu.process_mode
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	game.visible = true
	show_default_character()

func clear_all_connects(game):
	clear_connects(game.player_has_win)
	clear_connects(game.player_has_lose)

func clear_connects(sig):
	for c in sig.get_connections(): 
		sig.disconnect(c.callable)

func switch_to_other_connect(old_sig, new_sig):
	for c in old_sig.get_connections(): 
		new_sig.connect(c.callable)
		old_sig.disconnect(c.callable)
		
func switch_to_other_game(_game_type):
	if current_game:
		switching_game = true
		turn_off_game(current_game)
		var game = get_minigames(_game_type)
		clear_all_connects(game)
		switch_to_other_connect(current_game.player_has_win, game.player_has_win)
		game.player_has_win.connect(func():
			visible = false
			turn_off_game(game)
			)
		switch_to_other_connect(current_game.player_has_lose, game.player_has_lose)
		game.player_has_lose.connect(func():
			visible = false
			turn_off_game(game)
			)
		turn_on_game(game)
		game.run()
		switching_game = false

func show_default_character():
	enable_visible_character(true)
	character_left.load_default_char_face()
	character_right.load_default_char_face()

func enable_visible_character(enable):
	character_left.visible = enable
	character_right.visible = enable
