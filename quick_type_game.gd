extends VBoxContainer

var keycode_arr = [
	KEY_A, KEY_S, KEY_D
]
var texts = [
	["ตะเกียบ", "คีบ", "เนื้อ"],
	["กัมมัน", "ตรัง", "สี"],
]
signal player_has_win
signal player_has_lose
var time_to_play = 3
var win_max = 1
var current_win = 3
var text_arr_checker
var text_arr_input = []
var currect_i_checker = 0
var choices_text
var choice_boxes
var choices_default_color
var choices_correct_color = Color(0,1,0,1)
var choices_incorrect_color = Color(1,0,0,1)
var show_boxes
@onready var question_text = $question_text
@onready var show_text = $show_text
@onready var choices = $choices
@onready var timer_show = $timer_show
@onready var win_count = $win_count
var timer_show_tween
# Called when the node enters the scene tree for the first time.
func _ready():
	set_text_question()
	choice_boxes = choices.get_children()
	show_boxes = show_text.get_children()
	choices_default_color = choice_boxes[0].get_node("word").get_theme_color("font_color")

func run():
	set_choice_key()
	timer_show.value = timer_show.max_value
	current_win = 0
	set_show_win_count()
	set_text_question()
	run_show_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
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
			set_respond_color(box.get_node("word"), insert_word(box.get_node("word").text))

func insert_word(word):
	currect_i_checker = currect_i_checker % text_arr_checker.size()
	var current_word_check = text_arr_checker[currect_i_checker]
	if current_word_check == word:
		currect_i_checker = currect_i_checker + 1
		text_arr_input.push_back(current_word_check)
		set_show_answer()
		checker()
		return choices_correct_color
	currect_i_checker = 0
	reset_show_answer()
	return choices_incorrect_color

func checker():
	if text_arr_checker.size() == text_arr_input.size():
		currect_i_checker = 0
		set_text_question()
		reset_show_answer()
		increase_win_count()
		win_checker()

func win_checker():
	if current_win >= win_max:
		if timer_show_tween:
			timer_show_tween.kill()
		player_has_win.emit()
	elif  timer_show.value <= 0:
		player_has_lose.emit()

func get_random_text():
	randomize()
	return texts[randi_range(0, texts.size()-1)]

func set_question_text(_text_arr):
	var full_text = ""
	for t in _text_arr:
		full_text = full_text + t
	question_text.text = full_text

func set_choices_text(_text_arr):
	var dupe_text_arr = _text_arr.duplicate()
	dupe_text_arr.shuffle()
	var c_children = choices.get_children()
	var i = 0
	for child in c_children:
		child.get_node("word").text = dupe_text_arr[i]
		i = i + 1
	return dupe_text_arr

func set_choice_key():
	var i = 0
	var c_children = choices.get_children()
	for child in c_children:
		child.get_node("key").text = "[" + OS.get_keycode_string(keycode_arr[i]) + "]"
		i = i + 1

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

func set_text_question():
	text_arr_checker = get_random_text()
	set_question_text(text_arr_checker)
	choices_text = set_choices_text(text_arr_checker)

func set_show_answer():
	for i in range(0, text_arr_input.size()):
		show_boxes[i].text = text_arr_input[i]

func reset_show_answer():
	text_arr_input = []
	clear_show_answer()

func clear_show_answer():
	for box in show_boxes:
		box.text = ""

func set_respond_color(obj, color):
	set_obj_font_color(obj, color)
	if is_inside_tree():
		get_timer_to_default_color(obj).start()

func set_show_win_count():
	win_count.get_node("counter").text = str(current_win)
	win_count.get_node("max").text = str(win_max)

func increase_win_count():
	current_win = current_win + 1
	set_show_win_count()
	set_respond_color(win_count.get_node("counter"), choices_correct_color)

func run_show_timer():
	timer_show_tween = create_tween()
	timer_show_tween.tween_property(timer_show, "value", 0, time_to_play)
	timer_show_tween.tween_callback(func():
		win_checker()
		)
