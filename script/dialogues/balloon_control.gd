extends Node

@onready var balloon = DialogueUtill.get_balloon()
var on_finish_fn

func _ready():
	DialogueManager.dialogue_ended.connect(do_on_finished)

func do_on_finished(_resource):
	var menu = get_tree().get_first_node_in_group(GroupsName.MENU)
	if menu and is_instance_valid(menu):
		menu.process_mode = Node.PROCESS_MODE_DISABLED
	if on_finish_fn:
		var blur = get_tree().get_first_node_in_group(GroupsName.BLUR_SCREEN_CONTROL)
		if blur and is_instance_valid(blur):
			blur.get_parent().remove_child(blur)
			get_tree().get_first_node_in_group(GroupsName.BLUR_POS).add_child(blur)
			menu = get_tree().get_first_node_in_group(GroupsName.MENU_SET)
			menu.get_parent().remove_child(menu)
			get_tree().get_first_node_in_group(GroupsName.MAIN_MENU_POS).add_child(menu)
		on_finish_fn.call()
		reset_on_finish_fn()

func set_on_finish_balloon(_on_finish_fn):
	self.on_finish_fn = _on_finish_fn

func reset_on_finish_fn():
	on_finish_fn = null
