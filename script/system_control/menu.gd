extends Container

@onready var key_utill = KeyUtill
var resume

var is_main_menu = false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_main_menu = visible
	add_to_group(GroupsName.INPUT_GROUP)
	add_to_group(GroupsName.MENU)
	resume = find_child("resume")
	if resume:
		resume.pressed.connect(do_resume)
	
	if is_main_menu:
		ChangePage.current_page = self

func _input(event):
	if key_utill.is_just_pressed(GameControlKeycode.current_key[GameControlKeycode.KEY.MENU]) and not event.is_echo():
		if ChangePage.is_current_page_show() and ChangePage.current_page != self:
			ChangePage.change_to_prev_page()
		else:
			if not is_main_menu:
				do_resume()

func do_resume():
	if ChangePage.is_current_page_show() and ChangePage.current_page == self:
		get_tree().paused = false
		get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_out()
	else:
		get_tree().paused = true
		get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL).blur_in()
	if ChangePage.is_current_page_show():
		ChangePage.change_to_target_page()
	elif not visible:
		ChangePage.change_to_target_page(self)
