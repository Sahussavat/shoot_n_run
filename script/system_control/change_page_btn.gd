extends Button

@export var page_target : Node
@export var to_previous = false

func _ready():
	pressed.connect(to_page)

func to_page():
	if to_previous:
		ChangePage.change_to_prev_page()
		return
	ChangePage.change_to_target_page(page_target)
