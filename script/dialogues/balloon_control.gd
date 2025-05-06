extends Node

@onready var balloon = DialogueUtill.get_balloon()
var on_finish_fn

func _ready():
	DialogueManager.dialogue_ended.connect(do_on_finished)

func do_on_finished(_resource):
	if on_finish_fn:
		on_finish_fn.call()
		reset_on_finish_fn()

func set_on_finish_balloon(_on_finish_fn):
	self.on_finish_fn = _on_finish_fn

func reset_on_finish_fn():
	on_finish_fn = null
