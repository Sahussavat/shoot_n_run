extends Node

enum dialogue_box_type {
	TRANSPARENT,
	DEFAULT
}

var bg_default_path = "res://img/bg/%s"

var circle_transition = preload("res://shader/circle_transition.gdshader")
var balloon_template = preload("res://nodes/dialogue/balloon.tscn")
var balloon
var run_other_cutscene_fn

func set_background(bg_name = null):
	var background = get_balloon().get_node("Balloon/background")
	var background_load = get_balloon().get_node("Balloon/background_load")
	var pic_path = bg_default_path % bg_name
	var do_fade_in_for_black = false
	
	if not background_load.texture:
		do_fade_in_for_black = true
	
	if ResourceLoader.exists(pic_path):
		if do_fade_in_for_black:
			background_load.self_modulate = Color(1, 1, 1, 0)
		background_load.texture = ResourceLoader.load(pic_path)
	else:
		background_load.texture = null
	var tween = get_tree().create_tween()
	tween.set_pause_mode(tween.TWEEN_PAUSE_PROCESS)
	if do_fade_in_for_black:
		tween.tween_property(background_load, "self_modulate",Color(1, 1, 1, 1), 0.5 )
	else:
		tween.tween_property(background, "self_modulate",Color(1, 1, 1, 0), 0.5 )
	tween.tween_callback(func():
		if background:
			background.texture = background_load.texture
			background.self_modulate = Color(1, 1, 1, 1)
		)

func set_background_fade_in():
	set_background()

func set_dialogue_box_type(box_type):
	var box = get_balloon().get_node("Balloon/Panel")
	match box_type:
		dialogue_box_type.DEFAULT:
			box.remove_theme_stylebox_override("panel")
		dialogue_box_type.TRANSPARENT:
			box.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

func circle_in(call_back = null):
	var black_screen = get_balloon().get_node("Balloon/black_screen_control")
	if run_other_cutscene_fn:
		call_back = run_other_cutscene_fn
		run_other_cutscene_fn = null
	black_screen.circle_in(call_back)

func circle_out(call_back = null):
	var black_screen = get_balloon().get_node("Balloon/black_screen_control")
	black_screen.circle_out(call_back)

func get_balloon():
	if (not is_instance_valid(balloon) or not balloon) and get_tree().get_first_node_in_group(GroupsName.BALLOON_BOX):
		balloon = balloon_template.instantiate()
		var black_fade = balloon.get_node("Balloon/black_screen_control/black_fade")
		black_fade.material = ShaderMaterial.new()
		black_fade.material.shader = circle_transition
		black_fade.material.set_shader_parameter("circle_size", 0.0)
		black_fade.color.a = 1
		var balloon_box = get_tree().get_first_node_in_group(GroupsName.BALLOON_BOX)
		balloon_box.add_child(balloon)
	return balloon
