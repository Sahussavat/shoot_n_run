extends Button

@export var world_target : StringName

func _ready():
	pressed.connect(to_world)

func to_world():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(change_to_world)

func change_to_world():
	ChangePage.change_to_target_scene(world_target)
	
