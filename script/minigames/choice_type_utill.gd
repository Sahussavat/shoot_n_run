extends Node

var keycode_arr = [
	KEY_A, KEY_S, KEY_D
]

var time_to_play = 3
var win_max = 3
var current_win = 0
var choices_default_color
var choices_correct_color = Color(0,1,0,1)
var choices_incorrect_color = Color(1,0,0,1)
var choices
var win_count
var choice_boxes
var minigame
var minigame_control
var timer_show
var timer_show_tween

func _init(_minigame, _win_max = 3, _time_to_play = 3):
	self.minigame = _minigame
	minigame_control = minigame.get_tree().get_first_node_in_group(GroupsName.MINIGAMES)
	self.win_max = _win_max
	self.time_to_play = _time_to_play
	choices = minigame.get_node("choices")
	win_count = minigame.get_node("win_count")
	timer_show = minigame.get_node("timer_show")
	
	for i in range(0, keycode_arr.size()):
		var hbbox = HBoxContainer.new()
		var ans_label = Label.new()
		var key_label = Label.new()
		var label_arr = [key_label, ans_label]
		choices.add_child(hbbox)
		for l in label_arr:
			var f = load("res://fonts/upceb.ttf")
			l.add_theme_font_override("font", f)
			l.add_theme_font_size_override("font_size", 50)
			hbbox.add_child(l)
		ans_label.name = "ans"
		key_label.name = "key"
	
	choice_boxes = choices.get_children()
	choices_default_color = choice_boxes[0].get_node("ans").get_theme_color("font_color")

func choice_input(event, get_ans_color_fn):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if event is InputEventKey and just_pressed:
		var i
		if event.physical_keycode == KEY_A:
			i = 0
		elif event.physical_keycode == KEY_S:
			i = 1
		elif event.physical_keycode == KEY_D:
			i = 2
		if i != null:
			var box = choice_boxes[i]
			set_respond_color(box.get_node("ans"), get_ans_color_fn.call(box.get_node("ans")))

func set_obj_font_color(obj, color):
	obj.set("theme_override_colors/font_color", color)

func get_timer_to_default_color(obj):
	var children = obj.get_children()
	for child in children:
		if child is Timer:
			return child
	var to_default_color_timer = Timer.new()
	to_default_color_timer.wait_time = 0.25
	to_default_color_timer.one_shot = true
	to_default_color_timer.timeout.connect(func():
		set_obj_font_color(obj ,choices_default_color)
		)
	obj.add_child(to_default_color_timer)
	return to_default_color_timer

func set_respond_color(obj, color):
	set_obj_font_color(obj, color)
	if minigame.is_inside_tree():
		get_timer_to_default_color(obj).start()

func set_choice_key():
	var i = 0
	var c_children = choices.get_children()
	for child in c_children:
		child.get_node("key").text = "[" + OS.get_keycode_string(keycode_arr[i]) + "]"
		i = i + 1

func set_show_win_count():
	win_count.get_node("counter").text = str(current_win)
	win_count.get_node("max").text = str(win_max)

func increase_current_win():
	minigame_control.character_right.hurt()
	current_win = current_win + 1
	set_show_win_count()
	set_respond_color(win_count.get_node("counter"), choices_correct_color)

func decrease_current_win():
	minigame_control.character_left.hurt()
	if current_win > 0:
		current_win = current_win - 1
	set_show_win_count()
	set_respond_color(win_count.get_node("counter"), choices_incorrect_color)

func win_checker():
	if current_win >= win_max:
		if timer_show_tween:
			timer_show_tween.kill()
		minigame.player_has_win.emit()
	elif  timer_show.value <= 0:
		minigame.player_has_lose.emit()
	#elif current_win < win_max:
		#if timer_show_tween:
			#timer_show_tween.kill()
		#run_show_timer()

func run_show_timer():
	timer_show.value = timer_show.max_value
	timer_show_tween = minigame.create_tween()
	timer_show_tween.tween_property(timer_show, "value", 0, time_to_play)
	timer_show_tween.tween_callback(func():
		win_checker()
		)
