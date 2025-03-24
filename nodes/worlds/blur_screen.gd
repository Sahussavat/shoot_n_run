extends Control

var blur_shader = preload("res://shader/blur.gdshader")
@onready var blur_screen = get_node("blur")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.BLUR_SCREEN_CONTROL)
	blur_screen.visible = false

func blur_in(call_back = null, t = 0.1, turn_out = 5.0 ):
	blur_screen.texture = get_viewport().get_texture()
	blur_screen.visible = true
	var tween = create_tween()
	if not blur_screen.material:
		blur_screen.material = ShaderMaterial.new()
		blur_screen.material.shader = blur_shader
		blur_screen.material.set_shader_parameter("sigma", 0.0)
	tween.tween_property(blur_screen.material, "shader_parameter/sigma", turn_out, t)
	if call_back:
		tween.tween_callback(call_back)
	
func blur_out(call_back = null, t = 0.25):
	blur_in(func():
		if call_back:
			call_back.call()
			blur_screen.texture = null
		blur_screen.visible = false
		blur_screen.material = null, t, 0.0)
