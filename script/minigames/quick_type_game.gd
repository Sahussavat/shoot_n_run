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
var text_arr_checker
var text_arr_input = []
var currect_i_checker = 0
var choices_text
var choice_boxes
var choices_default_color
var choices_correct_color = Color(0,1,0,1)
var choices_incorrect_color = Color(1,0,0,1)
var show_boxes
@onready var choice_type_utill = preload("res://script/minigames/choice_type_utill.gd")
@onready var question_text = $question_text
@onready var show_text = $show_text
@onready var choices = $choices
@onready var timer_show = $timer_show
@onready var win_count = $win_count
var timer_show_tween
# Called when the node enters the scene tree for the first time.
func _ready():
	set_text_question()
	choice_type_utill = choice_type_utill.new(self)
	choice_boxes = choices.get_children()
	show_boxes = show_text.get_children()

func run():
	choice_type_utill.set_choice_key()
	choice_type_utill.current_win = 0
	choice_type_utill.set_show_win_count()
	set_text_question()
	choice_type_utill.run_show_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	choice_type_utill.choice_input(event, insert_word)

func insert_word(word):
	currect_i_checker = currect_i_checker % text_arr_checker.size()
	var current_word_check = text_arr_checker[currect_i_checker]
	if current_word_check == word.text:
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
		choice_type_utill.increase_current_win()
		choice_type_utill.win_checker()

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
		child.get_node("ans").text = dupe_text_arr[i]
		i = i + 1
	return dupe_text_arr

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

