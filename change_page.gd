extends Node

var current_page : Node
var prev_page : Node

func change_to_target_page(target_page : Node = null):
	
	if current_page:
		current_page.visible = false
	if target_page:
		target_page.visible = true
		prev_page = current_page
		current_page = target_page

func change_to_prev_page():
	if prev_page:
		change_to_target_page(prev_page)
		prev_page = null

func is_current_page_show():
	if current_page and is_instance_valid(current_page):
		return current_page.visible
	return false

func change_to_target_scene(scene_path):
	get_tree().paused = false
	var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
	if floors_control:
		var spawn_control = floors_control.spawn_control
		spawn_control.force_stop_all_events()
		floors_control.stop_loop()
	current_page = null
	get_tree().change_scene_to_file(scene_path)
