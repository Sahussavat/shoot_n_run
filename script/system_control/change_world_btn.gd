extends Button

@export var world_target : String
@export var reload_world = false
@export var next_world = false

func _ready():
	pressed.connect(to_world)
	
	if next_world and ChangePage.stored_next_world:
		visible = true

func to_world():
	get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(change_to_world)

func change_to_world():
	await get_tree().create_timer(0.1).timeout
	if reload_world:
		ChangePage.reload_current_scene()
	elif next_world:
		ChangePage.change_to_target_scene(ChangePage.stored_next_world)
		ChangePage.reset_store_next_world()
	else:
		ChangePage.change_to_target_scene(world_target)
	
