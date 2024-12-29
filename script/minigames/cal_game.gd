extends Node

enum arth_sign {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

signal player_has_win
signal player_has_lose
var correct_ans
var timer_show_tween
var choice_boxes

@onready var choice_type_utill = preload("res://script/minigames/choice_type_utill.gd")
@onready var timer_show = $timer_show
@onready var choices = $choices
@onready var win_count = $win_count
@onready var question_text = $question
@onready var num1 = question_text.get_node("num1")
@onready var num2 = question_text.get_node("num2")
@onready var arth = question_text.get_node("arth_sign")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_question()
	choice_type_utill = choice_type_utill.new(self, 3, 20)
	choice_boxes = choices.get_children()

func run():
	choice_type_utill.set_choice_key()
	choice_type_utill.current_win = 0
	choice_type_utill.set_show_win_count()
	set_question()
	set_choices()
	choice_type_utill.run_show_timer()

func _input(event):
	choice_type_utill.choice_input(event, get_ans_color)

func checker(chosen_ans):
	if correct_ans == chosen_ans:
		set_question()
		set_choices()
		choice_type_utill.increase_current_win()
		choice_type_utill.win_checker()

func get_ans_color(ans):
	if correct_ans == int(ans.text):
		checker(int(ans.text))
		return choice_type_utill.choices_correct_color
	choice_type_utill.decrease_current_win()
	return choice_type_utill.choices_incorrect_color

func set_question():
	var n1
	var n2
	match arth_sign.values().pick_random():
		arth_sign.ADD:
			arth.text = "+"
			n1 = randi_range(0, 50)
			n2 = randi_range(0, 50)
			correct_ans = n1 + n2
		arth_sign.SUBTRACT:
			arth.text = "-"
			n1 = randi_range(0, 50)
			n2 = randi_range(0, n1)
			correct_ans = n1 - n2
		arth_sign.MULTIPLY:
			arth.text = "x"
			n1 = randi_range(0, 10)
			n2 = randi_range(0, 10)
			correct_ans = n1 * n2
		arth_sign.DIVIDE:
			arth.text = "÷"
			n2 = randi_range(1, 10)
			correct_ans = randi_range(0, 10)
			n1 = n2 * correct_ans
	
	#set_label_text
	num1.text = str(n1)
	num2.text = str(n2)

func set_choices():
	var c_children = choices.get_children()
	var right_ans_pos = randi_range(0, c_children.size() - 1)
	for i in range(0, c_children.size()):
		if i == right_ans_pos:
			c_children[i].get_node("ans").text = str(correct_ans)
		else:
			var n = [1, -1]
			c_children[i].get_node("ans").text = str(correct_ans + randi_range(1, 10) * n[randi_range(0, n.size() - 1)])
