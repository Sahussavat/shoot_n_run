extends Node2D

signal stop_events

func _ready():
	if not is_in_group(GroupsName.SPAWN_CONTROL):
		add_to_group(GroupsName.SPAWN_CONTROL)

func create(run_event):
	return run_event.new(self)

func force_stop_all_events():
	stop_events.emit()
	remove_all_enemies()

func remove_all_enemies():
	get_tree().call_group(GroupsName.ENEMIES, "destroy")
	
