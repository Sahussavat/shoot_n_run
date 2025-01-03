extends Button

@export var world_target : StringName

func _ready():
	pressed.connect(to_world)

func to_world():
	ChangePage.change_to_target_scene(world_target)
