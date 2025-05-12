extends Node

var default_world_path = "res://nodes/worlds/%s.tscn"
var current_page : Node
var prev_page : Node

var stored_next_world
var is_changing_page = false

func change_to_target_page(target_page : Node = null):
	
	if current_page:
		current_page.visible = false
	if target_page:
		target_page.visible = true
		prev_page = current_page
		if target_page.is_in_group(GroupsName.PAGE_WRAP):
			current_page = target_page.get_node(target_page.focus_neighbor_bottom)
		else:
			current_page = target_page
		var f = get_first_focus_child(current_page)
		if f:
			f.grab_focus()

func get_first_focus_child(parent):
	var arr = parent.get_children()
	while arr.size() > 0:
		var c = arr[0]
		if c.get_children().size() > 0:
			for _c in c.get_children():
				arr.append(_c)
		if c.is_in_group(GroupsName.FOCUS_FIRST) and c.visible:
			return c
		arr.remove_at(0)
	return null

func change_to_prev_page():
	if current_page and \
		not current_page.focus_neighbor_left and current_page.get_parent().is_in_group(GroupsName.PAGE_WRAP) and current_page.get_parent().focus_neighbor_left:
		current_page = current_page.get_parent()
	if current_page and current_page.focus_neighbor_left:
		change_to_target_page(current_page.get_node(current_page.focus_neighbor_left))

func is_current_page_show():
	if current_page and is_instance_valid(current_page):
		return current_page.visible
	return false

func change_to_target_scene(scene_path):
	get_tree().paused = false
	var floors_control = get_tree().get_first_node_in_group(GroupsName.FLOOR_CONTROL)
	if floors_control:
		floors_control = floors_control.floor_control
		var spawn_control = floors_control.spawn_control
		spawn_control.force_stop_all_events()
		floors_control.stop_loop()
	current_page = null
	var world
	if scene_path is Node:
		world = load((default_world_path % scene_path.name).to_lower()).instantiate()
	else:
		world = load(scene_path).instantiate()
	var blank_world = load(default_world_path % "blank").instantiate()
	var current_sc = get_tree().current_scene
	is_changing_page = true
	get_tree().root.add_child(blank_world)
	get_tree().current_scene = blank_world
	get_tree().root.remove_child(current_sc)
	get_tree().root.add_child(world)
	get_tree().current_scene = world
	get_tree().root.remove_child(blank_world)
	is_changing_page = false
	current_sc.queue_free()

func reload_current_scene():
	var cur = (default_world_path % get_tree().current_scene.name).to_lower()
	change_to_target_scene(cur)

func store_next_world(world_name):
	stored_next_world = default_world_path % world_name

func reset_store_next_world():
	stored_next_world = null
