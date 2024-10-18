extends AnimationTree

@onready var player_body = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	set("parameters/jump_up/blend_position", player_body.get_mouse_direction())
	set("parameters/jump_down/blend_position", player_body.get_mouse_direction())
	set("parameters/run/blend_position", player_body.get_mouse_direction())
	set("parameters/dash/blend_position", player_body.get_mouse_direction())
