extends Node

var default_world_path = "res://nodes/worlds/%s.tscn"
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
	var world
	if scene_path is Node:
		world = load((default_world_path % scene_path.name).to_lower()).instantiate()
	else:
		world = load(scene_path).instantiate()
	var current_sc = get_tree().current_scene
	get_tree().root.add_child(world)
	get_tree().current_scene = world
	get_tree().root.remove_child(current_sc)
	current_sc.queue_free()

func reload_current_scene():
	var cur = (default_world_path % get_tree().current_scene.name).to_lower()
	change_to_target_scene(default_world_path % "blank")
	change_to_target_scene(cur)
