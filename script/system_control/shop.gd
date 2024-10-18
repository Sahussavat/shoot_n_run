extends Node2D

@onready var balloon = $Balloon

# Called when the node enters the scene tree for the first time.
func _ready():
	run_init_scene()
	print("onces")

func run_init_scene():
	balloon.start(load("res://dialogues/test1_dialog.dialogue"), "this_is_a_node_title")
