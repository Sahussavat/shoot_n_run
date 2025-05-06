extends Control

@export var world_target : String
@export var is_instant_transition = false
@onready var skip_container = $skip_container
var done_skip = false

func _ready():
	skip_container.on_finished_skip.connect(func(): 
		done_skip = true
		end())
	skip_container.enable_skip = true

func end():
	if is_instant_transition:
		change_to_world()
	else:
		get_tree().get_first_node_in_group(GroupsName.BLACK_SCREEN_CONTROL).circle_in(change_to_world)

func change_to_world():
	await get_tree().create_timer(0.1).timeout
	ChangePage.change_to_target_scene(world_target)
