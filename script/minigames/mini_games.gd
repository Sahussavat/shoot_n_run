extends PanelContainer

enum game_type {
	QUICK_TYPE, ##minigame ประเภทพิมพ์เร็ว
	SPEECH_TYPE, ##minigame ประเภทพูดตามคำบอก
	CALCULATE_TYPE, ##minigame ประเภทคิดเลขไว
}

var current_game

# Called when the node enters the scene tree for the first time.
func run_the_game(_game_type, win_fn, lose_fn):
	visible = true
	current_game = get_minigames(_game_type)
	if current_game:
		var game = current_game
		clear_all_connects(game)
		game.player_has_win.connect(func():
			turn_off_game(game)
			win_fn.call()
			visible = false
			)
		game.player_has_lose.connect(func():
			turn_off_game(game)
			lose_fn.call()
			visible = false
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
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.visible = false

func turn_on_game(game):
	game.process_mode = Node.PROCESS_MODE_ALWAYS
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
		switch_to_other_connect(current_game.player_has_lose, game.player_has_lose)
		turn_on_game(game)
		game.run()
