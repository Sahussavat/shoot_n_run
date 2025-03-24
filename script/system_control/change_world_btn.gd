extends Button

@export var world_target : String

func _ready():
	pressed.connect(to_world)

func to_world():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(change_to_world)

func change_to_world():
	await get_tree().create_timer(0.1).timeout
	ChangePage.change_to_target_scene(world_target)
	
