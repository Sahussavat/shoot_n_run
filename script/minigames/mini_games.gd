extends PanelContainer

enum game_type {
	QUICK_TYPE, ##minigame ประเภทพิมพ์เร็ว
	SPEECH_TYPE, ##minigame ประเภทพูดตามคำบอก
	CALCULATE_TYPE, ##minigame ประเภทคิดเลขไว
}

var menu
var temp_menu_process_mode = PROCESS_MODE_INHERIT

var current_game

# Called when the node enters the scene tree for the first time.
func run_the_game(_game_type, win_fn, lose_fn):
	visible = true
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
		turn_on_game(game)
		game.run()

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
	menu.process_mode = temp_menu_process_mode

func turn_on_game(game): 
	game.process_mode = Node.PROCESS_MODE_ALWAYS
	temp_menu_process_mode = menu.process_mode
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	game.visible = true

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
