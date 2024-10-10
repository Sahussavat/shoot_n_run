extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_in_group(GroupsName.BOSS_BAR):
		add_to_group(GroupsName.BOSS_BAR)
