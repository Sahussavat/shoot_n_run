extends Node

var circle_transition = preload("res://shader/circle_transition.gdshader")
var tween
@onready var black_fade = $black_fade
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
	#add_to_group(GroupsName.BLACK_SCREEN_CONTROL)
	
func do_fade_black(call_back):
	fade_in(call_back)

func fade_in(call_back):
	black_fade.visible = true
	tween = create_tween()
	tween.tween_property(black_fade, "color", Color.BLACK, 0.25)
	tween.tween_callback(func():
		call_back.call()
		fade_out()
		)

func fade_out():
	tween = create_tween()
	var _color = Color.BLACK
	_color.a = 0
	tween.tween_property(black_fade, "color", _color, 1)
	tween.tween_callback(func():
		black_fade.visible = false
		)

func circle_in(call_back = null, turn_out = 0.0):
	black_fade.visible = true
	tween = create_tween()
	if not black_fade.material:
		black_fade.material = ShaderMaterial.new()
		black_fade.material.shader = circle_transition
		black_fade.material.set_shader_parameter("circle_size", 1.0)
		black_fade.color.a = 1
	tween.tween_property(black_fade.material, "shader_parameter/circle_size", turn_out, 1)
	if call_back:
		tween.tween_callback(call_back)
	
func circle_out(call_back = null):
	if tween:
		tween.kill()
	if black_fade.material:
		black_fade.material.set_shader_parameter("circle_size", 0.0)
	circle_in(func():
		if call_back:
			call_back.call()
		black_fade.color.a = 0
		black_fade.visible = false
		black_fade.material = null, 1.0)
