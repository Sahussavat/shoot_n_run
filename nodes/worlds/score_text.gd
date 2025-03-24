extends Control

@onready var current_score_text = get_node("score_text/current_score/score")
@onready var highest_score_text = get_node("score_text/highest_score/score")
# Called when the node enters the scene tree for the first time.
func _ready():
	current_score_text.text = str(ScoreControl.score)
	var h_s = ScoreControl.load_highest_score()
	if h_s < ScoreControl.score:
		highest_score_text.text = current_score_text.text
		ScoreControl.save_highest_score()
	else:
		highest_score_text.text = str(h_s)
