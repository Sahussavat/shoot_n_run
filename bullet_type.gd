extends Node

const RED = "red"
const GREEN = "green"
const YELLOW = "yellow"

var type = [
	RED,
	GREEN,
	YELLOW
]

var type_color = {
	RED: Vector4(1,0,0,1),
	GREEN: Vector4(0,1,0,1),
	YELLOW: Vector4(1,1,0,1)
}

func is_can_hit(target, doer):
	var is_target_in_some_group = false
	for t in type:
		var is_target_in_group = target.is_in_group(t)
		var is_doer_in_group = doer.is_in_group(t)
		if not is_target_in_some_group and is_target_in_group:
			is_target_in_some_group = true
		var is_all_in_group = is_target_in_group and is_doer_in_group
		if is_all_in_group:
			return true
	return not is_target_in_some_group

func remove_to_all_type(target):
	for t in type:
		if target.is_in_group(t):
			target.remove_from_group(t)

func get_bullet_type_color(_type):
	return type_color[_type]
