extends Control

var blur_shader = preload("res://shader/blur.gdshader")
@onready var blur_screen = get_node("blur")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupsName.BLUR_SCREEN_CONTROL)
	blur_screen.visible = false

func blur_in(call_back = null, t = 0.1, turn_out = 1.0 ):
	blur_screen.visible = true
	var tween = create_tween()
	#if not blur_screen.material:
		#blur_screen.material = ShaderMaterial.new()
		#blur_screen.material.shader = blur_shader
	tween.tween_method(blur, 1.0 - turn_out, turn_out, t)
	if call_back:
		tween.tween_callback(call_back)
	
func blur_out(call_back = null, t = 0.25):
	blur_in(func():
		if call_back:
			call_back.call()
		blur_screen.visible = false
		blur_screen.material = null, t, 0.0)

func blur(percentage):
	blur_screen.color.a = 0.25 * percentage
